# PostmarketOS on Xiaomi Note 10 Pro (WIP)

This repo is an attempt to port pmOS to Xiaomi Note 10 Pro, codename `tucana`. Not to be confused with Redmi Note 10 Pro, `sweet`. Almost identical names, and similar looks, but different guts. Also, sweet has a WIP port by Salvatore Stella [1].

## Status

Kernel compiles, but doesn't boot.

## Links

ext+treestyletab:group?title=general
https://www.gsmarena.com/xiaomi_mi_note_10_pro-9945.php
https://www.giznext.com/mobile-chipsets/qualcomm-snapdragon-730g-chipset-gnt
https://forum.xda-developers.com/f/xiaomi-mi-note-10-roms-kernels-recoveries-oth.9603/
https://forum.xda-developers.com/t/recovery-3-4-0-10-tucana-official-unofficial-twrp-xiaomi-mi-note-10-cc9-pro-stable.4015805/
https://forum.xda-developers.com/t/firmware-xiaomi-mi-note-10-pro-mi-cc-9-pro-tucana-auto-updated-daily.4096347/
https://forum.xda-developers.com/t/rom-a13-official-octavios.4554983/
https://sourceforge.net/projects/erikdrozina-builds/
ext+treestyletab:group?title=sweet+port
https://wiki.postmarketos.org/index.php?title=Xiaomi_Redmi_Note_10_Pro_(xiaomi-sweet)&mobileaction=toggle_view_desktop
https://github.com/TeamWin/android_device_xiaomi_sweet
https://gitlab.com/etn40ff/pmaports/-/tree/xiaomi-sweet/device/testing/linux-xiaomi-sweet
ext+treestyletab:group?title=wiki
https://wiki.postmarketos.org/wiki/Kernel_configuration#CONFIG_SWAP
https://wiki.postmarketos.org/wiki/Downstream_kernel_specific_package#GCC_version
https://wiki.postmarketos.org/wiki/Porting_to_a_new_device#Find_the_error_message
https://wiki.postmarketos.org/wiki/Mainlining_FAQ#Writing_dmesg_to_RAM_and_reading_it_out_after_reboot
https://wiki.postmarketos.org/wiki/Troubleshooting:boot
ext+treestyletab:group?title=arm+stuff
https://patchwork.ozlabs.org/project/uboot/patch/20171128020937.27906-1-peng.fan@nxp.com/
https://www.rowleydownload.co.uk/arm/documentation/gnu/gcc/AArch64-Options.html
https://bugs.llvm.org/show_bug.cgi?id=30792
https://reviews.llvm.org/D38479
https://patchwork.kernel.org/project/linux-kbuild/patch/20171129000011.55235-4-samitolvanen@google.com/
ext+treestyletab:group?title=kernels
https://github.com/OctaviOS-Devices/kernel_xiaomi_tucana
https://raw.githubusercontent.com/OctaviOS-Devices/kernel_xiaomi_tucana/12/arch/arm64/configs/tucana_defconfig
https://github.com/OctaviOS-Devices/kernel_xiaomi_tucana/blob/12/arch/arm64/configs/vendor/tucana_user_defconfig
https://raw.githubusercontent.com/OctaviOS-Devices/kernel_xiaomi_tucana/12/arch/arm64/configs/tucana_defconfig
https://github.com/OctaviOS-Devices/kernel_xiaomi_tucana/blob/12/build.config.aarch64
https://raw.githubusercontent.com/OctaviOS-Devices/kernel_xiaomi_tucana/12/arch/arm64/configs/vendor/tucana_user_defconfig
https://github.com/erikdrozina/kernel_xiaomi_sm6150
https://github.com/erikdrozina/kernel_xiaomi_sm6150/commits/12
https://github.com/erikdrozina/kernel_xiaomi_sm6150/blob/13/arch/arm64/configs/tucana_defconfig
https://github.com/erikdrozina/kernel_xiaomi_sm6150/commits/13
https://github.com/OctaviOS-Devices/kernel_xiaomi_tucana/tree/12

## Log

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
