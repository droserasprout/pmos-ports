# PostmarketOS on Xiaomi Note 10 Pro (WIP)

This repo is an attempt to port pmOS to Xiaomi Note 10 Pro, codename `tucana`. Not to be confused with Redmi Note 10 Pro, `sweet`. Almost identical names, and similar looks, but different guts.

## Status

Doesn't boot with any compiled or prebuilt kernel. /sys/fs/pstore is empty from recovery, so I have no idea how to proceed.

## Building 4.14.275 with GCC

I've initialized a new project and followed the "Porting to a new device" page. A working Android 13 ROM named OctaviOS is available for tucana, so both kernel and device tree are ready. I used this [2] defconfig. Initial check:

```
[00:22:38] WARNING: config-xiaomi-tucana.aarch64: CONFIG_DEVTMPFS should be set (postmarketOS): https://wiki.postmarketos.org/wiki/kconfig#CONFIG_DEVTMPFS
[00:22:38] WARNING: config-xiaomi-tucana.aarch64: CONFIG_DM_CRYPT should be set (postmarketOS): https://wiki.postmarketos.org/wiki/kconfig#CONFIG_DM_CRYPT
[00:22:38] WARNING: config-xiaomi-tucana.aarch64: CONFIG_SYSVIPC should be set (postmarketOS): https://wiki.postmarketos.org/wiki/kconfig#CONFIG_SYSVIPC
[00:22:38] WARNING: config-xiaomi-tucana.aarch64: CONFIG_VT should be set (postmarketOS): https://wiki.postmarketos.org/wiki/kconfig#CONFIG_VT
[00:22:38] WARNING: config-xiaomi-tucana.aarch64: CONFIG_USER_NS should be set (postmarketOS): https://wiki.postmarketos.org/wiki/kconfig#CONFIG_USER_NS
```

REPLACE_GCCH=0 is required. The first compilation error was "CROSS_COMPILE_ARM32 not defined or empty". I've disabled CONFIG_COMPAT_VDSO as wiki suggests and it's gone. The next one is more interesting:

```
../drivers/power/supply/ti/bq2597x_charger.c:178:24: note: in expansion of macro 'KERN_ERR'
  178 |                 printk(KERN_ERR "[bq2597x-STANDALONE]:%s:" fmt, __func__, ##__VA_ARGS__);\
      |                        ^~~~~~~~
../drivers/power/supply/ti/bq2597x_charger.c:2203:17: note: in expansion of macro 'bq_err'
 2203 |                 bq_err("failed to register fc2_psy:%d\n", PTR_ERR(bq->fc2_psy));
      |                 ^~~~~~
../drivers/power/supply/ti/bq2597x_charger.c: In function 'bq2597x_get_adc_data':
../drivers/power/supply/ti/bq2597x_charger.c:1107:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
 1107 |                         *result = (int)(t * sc8551_adc_lsb_non_calibrate[channel]);
      |                                   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
../drivers/power/supply/ti/bq2597x_charger.c:1107:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
../drivers/power/supply/ti/bq2597x_charger.c:1107:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
../drivers/power/supply/ti/bq2597x_charger.c:1107:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
../drivers/power/supply/ti/bq2597x_charger.c:1107:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
../drivers/power/supply/ti/bq2597x_charger.c:1107:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
../drivers/power/supply/ti/bq2597x_charger.c:1107:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
../drivers/power/supply/ti/bq2597x_charger.c:1107:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
../drivers/power/supply/ti/bq2597x_charger.c:1109:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
 1109 |                         *result = (int)(t * sc8551_adc_lsb[channel]);
      |                                   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
../drivers/power/supply/ti/bq2597x_charger.c:1109:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
../drivers/power/supply/ti/bq2597x_charger.c:1109:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
../drivers/power/supply/ti/bq2597x_charger.c:1109:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
../drivers/power/supply/ti/bq2597x_charger.c:1109:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
../drivers/power/supply/ti/bq2597x_charger.c:1109:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
../drivers/power/supply/ti/bq2597x_charger.c:1109:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
../drivers/power/supply/ti/bq2597x_charger.c:1109:35: error: '-mgeneral-regs-only' is incompatible with the use of floating-point types
make[5]: *** [../scripts/Makefile.build:365: drivers/power/supply/ti/bq2597x_charger.o] Error 1
```

These two failing lines are between kernel_neon_begin() and kernel_neon_end(). Something with those 32-bit vDTOs? Anyway, bq2597x_charger is one of the things sweet (early revisions) and tucana have in common. So, in the WIP sweet port I found a patch "fix_compilation.patch" [3] and copied the first part of it commenting out `-mgeneral-regs-only`. The kernel compiled successfully.

The boot process fails after 2-3 seconds. Stopping there now to publish preliminary results.

[1] https://gitlab.com/etn40ff/pmaports/-/tree/xiaomi-sweet/device/testing/linux-xiaomi-sweet
[2] https://raw.githubusercontent.com/OctaviOS-Devices/kernel_xiaomi_tucana/12/arch/arm64/configs/tucana_defconfig
[3] https://gitlab.com/etn40ff/pmaports/-/blob/xiaomi-sweet/device/testing/linux-xiaomi-sweet/fix_compilation.patch

### Building 4.14.299 with clang

In erikdrozina/kernel_xiaomi_sm6150 maintainer has switched to clang. Let's try it too since "try another codebase" is a valid strategy. Now it's 4.14.299. The only change in defconfig is CONFIG_CC_STACKPROTECTOR_NONE=y.

The latest run failed with:

```
../kernel/jump_label.c:242:6: warning: implicit declaration of function 'static_key_slow_try_dec' [-Wimplicit-function-declaration]
        if (static_key_slow_try_dec(key))
            ^
../kernel/jump_label.c:245:48: error: use of undeclared identifier 'work'; did you mean 'for'?
        queue_delayed_work(system_power_efficient_wq, work, timeout);
                                                      ^~~~
                                                      for
../kernel/jump_label.c:245:48: error: expected expression
../kernel/jump_label.c:245:54: error: use of undeclared identifier 'timeout'
        queue_delayed_work(system_power_efficient_wq, work, timeout);
                                                            ^
1 warning and 3 errors generated.
make[2]: *** [../scripts/Makefile.build:364: kernel/jump_label.o] Error 1
```

It was broken there: https://github.com/erikdrozina/kernel_xiaomi_sm6150/commit/50c395c19174e0bba0cc7ed5d2ddafc08222da3d

Disabling CONFIG_JUMP_LABEL=y in defconfig helps. The kernel compiles successfully, but doesn't boot.

### Prebuilt kernel

Doesn't work too, but for reference:

```
paru -Syu --noconfirm mkbootimg
mkdir uncompressed_boot
unpackbootimg -i boot.img -o uncompressed_boot
fastboot boot \                                    
--cmdline "console=ttyMSM0,115200n8 earlycon=msm_geni_serial,0x880000 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.usbcontroller=a600000.dwc3 service_locator.enable=1 lpm_levels.sleep_disabled=1 loop.max_part=7 kpti=off buildvariant=userdebug" uncompressed_boot/boot.img-kernel \
~/.cache/pmbootstrap/chroot_rootfs_xiaomi-tucana/boot/initramfs
```

## Links

### Device

- https://www.gsmarena.com/xiaomi_mi_note_10_pro-9945.php
- https://wiki.postmarketos.org/wiki/Qualcomm_Snapdragon_730/730G/732G_(SM7150)
- https://www.giznext.com/mobile-chipsets/qualcomm-snapdragon-730g-chipset-gnt

### ROMs and recoveries

- https://forum.xda-developers.com/f/xiaomi-mi-note-10-roms-kernels-recoveries-oth.9603/
- https://forum.xda-developers.com/t/recovery-3-4-0-10-tucana-official-unofficial-twrp-xiaomi-mi-note-10-cc9-pro-stable.4015805/
- https://forum.xda-developers.com/t/firmware-xiaomi-mi-note-10-pro-mi-cc-9-pro-tucana-auto-updated-daily.4096347/
- https://forum.xda-developers.com/t/rom-a13-official-octavios.4554983/
- https://sourceforge.net/projects/erikdrozina-builds/

### tucana kernels

- https://github.com/OctaviOS-Devices/kernel_xiaomi_tucana/tree/12
- https://github.com/OctaviOS-Devices/kernel_xiaomi_tucana/blob/12/arch/arm64/configs/tucana_defconfig

- https://github.com/erikdrozina/kernel_xiaomi_sm6150/tree/12
- https://github.com/erikdrozina/kernel_xiaomi_sm6150/blob/12/arch/arm64/configs/tucana_defconfig

- https://github.com/erikdrozina/kernel_xiaomi_sm6150/tree/13
- https://github.com/erikdrozina/kernel_xiaomi_sm6150/blob/13/arch/arm64/configs/tucana_defconfig


### `sweet` port

- https://wiki.postmarketos.org/index.php?title=Xiaomi_Redmi_Note_10_Pro_(xiaomi-sweet)
- https://github.com/TeamWin/android_device_xiaomi_sweet
- https://gitlab.com/etn40ff/pmaports/-/tree/xiaomi-sweet/device/testing/linux-xiaomi-sweet

### pmOS Wiki guides

- https://wiki.postmarketos.org/wiki/Kernel_configuration
- https://wiki.postmarketos.org/wiki/Downstream_kernel_specific_package
- https://wiki.postmarketos.org/wiki/How_to_find_device-specific_information
- https://wiki.postmarketos.org/wiki/Porting_to_a_new_device
- https://wiki.postmarketos.org/wiki/Troubleshooting:boot
- https://wiki.postmarketos.org/wiki/Troubleshooting:kernel
- https://wiki.postmarketos.org/wiki/Using_prebuilt_kernels
- https://wiki.postmarketos.org/wiki/Deviceinfo_reference
- https://wiki.postmarketos.org/wiki/Qualcomm_Glossary

### ARM64-specific stuff

- https://patchwork.ozlabs.org/project/uboot/patch/20171128020937.27906-1-peng.fan@nxp.com/
- https://www.rowleydownload.co.uk/arm/documentation/gnu/gcc/AArch64-Options.html
- https://bugs.llvm.org/show_bug.cgi?id=30792
- https://reviews.llvm.org/D38479
- https://patchwork.kernel.org/project/linux-kbuild/patch/20171129000011.55235-4-samitolvanen@google.com/

### Misc

#### Booted OctaviOS cmdline

```
cgroup_disable=pressure ramoops_memreserve=4M quiet rcupdate.rcu_expedited=1 rcu_nocbs=0-7 console=ttyMSM0,115200n8 earlycon=msm_geni_serial,0x880000 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.usbcontroller=a600000.dwc3 service_locator.enable=1 lpm_levels.sleep_disabled=1 loop.max_part=7 kpti=off buildvariant=userdebug androidboot.verifiedbootstate=orange androidboot.keymaster=1 root=PARTUUID=7ac9ae5d-bd8f-9066-32f4-b0f9c2facd3a androidboot.bootdevice=1d84000.ufshc androidboot.fstab_suffix=default androidboot.serialno=da6f2552 androidboot.ramdump=disable androidboot.secureboot=1 androidboot.cpuid=0x750f65e9 androidboot.hwversion=6.19.9 androidboot.hwc=GLOBAL androidboot.hwlevel=MP androidboot.baseband=msm msm_drm.dsi_display0=dsi_xiaomi_f4_41_06_0a_fhd_cmd_display: skip_initramfs rootwait ro init=/init androidboot.dtbo_idx=0 androidboot.dtb_idx=0 androidboot.dp=0x0
```
