.PHONY: $(MAKECMDGOALS)
MAKEFLAGS += --no-print-directory
##
##  🚧 pmOS scripts (ports)
##
PMAPORTS=~/.cache/pmbootstrap/cache_git/pmaports/device
PM=pmbootstrap --details-to-stdout -v

ZIP=~/.cache
OCTAVIOS_ZIP=${ZIP}/OctaviOS-v4.4-tucana-20230522-2003-VANILLA-Official.zip
MAGISK_ZIP=${ZIP}/Magisk-v26.1.zip

GREP_DUMPSYS=/sys/devices/platform/goodix_ts.0/driver_info
GREP_PORTS="dtc "

# CODENAME=raphael
# DEVICE=device-xiaomi-raphael
# KERNEL=linux-xiaomi-raphael

CODENAME=tucana
DEVICE=device-xiaomi-tucana
KERNEL=linux-postmarketos-qcom-sm7150

# CODENAME=gemini
# DEVICE=device-xiaomi-gemini
# KERNEL=linux-postmarketos-qcom-msm8996

##

help:               ## Show this help (default)
	@grep -Fh "##" $(MAKEFILE_LIST) | grep -Fv grep -F | sed -e 's/\\$$//' | sed -e 's/##//'

##

push:               ## Push device to pmaports directory
	rm -rf ${PMAPORTS}/testing/${DEVICE}
	# rm -rf ${PMAPORTS}/testing/${KERNEL}
	cp -r ${DEVICE} ${PMAPORTS}/testing
	# cp -r ${KERNEL} ${PMAPORTS}/testing
	make checksum

pull:               ## Pull device from pmaports directory
	rm -rf ${DEVICE}
	# rm -rf ${KERNEL}
	cp -r ${PMAPORTS}/testing/${DEVICE} .
	# cp -r ${PMAPORTS}/testing/${KERNEL} .

kconfig:            ## Edit kernel config
	${PM} kconfig edit
	make pull

build_kernel:       ## Build kernel
	${PM} build ${KERNEL}

build_kernel_force: ## Build kernel (force)
	${PM} build ${KERNEL} --force

build_device:       ## Build device
	${PM} build ${DEVICE}

build_device_force: ## Build device (force)
	${PM} build ${DEVICE}  --force

boot:               ## Boot device
	${PM} flasher boot

sideload_octavia:   ## Sideload OctaviOS to 'tucana'
	read
	adb reboot recovery
	read
	adb sideload ${OCTAVIOS_ZIP}
	read
	adb reboot recovery
	read
	adb sideload ${MAGISK_ZIP}
	read
	adb reboot

dump_running:       ## Dump kernel config and cmdline from running system
	adb shell zcat /proc/config.gz > from-${CODENAME}/config
	adb shell su -c cat /proc/cmdline > from-${CODENAME}/cmdline

dump_boot:          ## Dump boot.img
	adb shell su -c cat /dev/block/by-name/boot > /tmp/${CODENAME}-boot.img
	${PM} bootimg_analyze /tmp/${CODENAME}-boot.img > from-${CODENAME}/deviceinfo

dumpsys_recovery:   ## Dump dumpsys from recovery
	adb push dumpsys.sh /tmp/dumpsys.sh
	adb shell sh /tmp/dumpsys.sh | tee from-${CODENAME}/dumpsys_recovery

dumpsys_android:    ## Dump dumpsys from Android
	adb push dumpsys.sh /sdcard/dumpsys.sh
	adb shell 'su -c sh /data/media/dumpsys.sh' > from-${CODENAME}/dumpsys_android

dumpsys_compare:    ## Compare dumpsys from recovery and Android
	grep -A1 -h -r "${DUMPSYS}" .

telnet:             ## Telnet to device
	telnet 172.16.42.1
	# vi dumpsys.sh

checksum:           ## Checksum device and kernel packages
	${PM} checksum ${DEVICE}
	${PM} checksum ${KERNEL}

grep_ports:         ## Grep pmaports directory by substring
	grep -r ${GREP_PORTS} ${PMAPORTS}

##

install:            ## pm install
	${PM} install --fde

init:               ## pm init
	${PM} init

zap:                ## pm zap
	${PM} zap

update:             ## pm update
	${PM} update

test_deviceinfo:
	make push build_device_force
	sudo env -i /usr/bin/sh -c "chroot ~/.cache/pmbootstrap/chroot_rootfs_xiaomi-tucana /bin/sh -c 'apk fix ${DEVICE}'"

##