PMAPORTS=~/.cache/pmbootstrap/cache_git/pmaports/device/testing/
CACHE=~/.cache

CODENAME=raphael
DEVICE=device-xiaomi-raphael
KERNEL=linux-xiaomi-raphael

# CODENAME=tucana
# DEVICE=device-xiaomi-tucana
# KERNEL=linux-xiaomi-tucana-octavios

# CODENAME=tucana
# DEVICE=device-xiaomi-tucana
# KERNEL=linux-xiaomi-tucana-erikdrozina

push:
	rm -rf ${PMAPORTS}/${DEVICE}
	rm -rf ${PMAPORTS}/${KERNEL}
	cp -r ${DEVICE} ${PMAPORTS}
	cp -r ${KERNEL} ${PMAPORTS}
	pmbootstrap checksum ${DEVICE}
	pmbootstrap checksum ${KERNEL}

pull:
	rm -rf ${DEVICE}
	rm -rf ${KERNEL}
	cp -r ${PMAPORTS}/${DEVICE} .
	cp -r ${PMAPORTS}/${KERNEL} .

kconfig:
	pmbootstrap kconfig edit
	make pull

build:
	pmbootstrap build ${DEVICE} --force
	pmbootstrap build ${KERNEL} --force

boot:
	pmbootstrap flasher --method fastboot boot

sideload_octavia:
	read
	adb reboot recovery
	read
	adb sideload ${CACHE}/OctaviOS-v4.4-tucana-20230522-2003-VANILLA-Official.zip
	read
	adb reboot recovery
	read
	adb sideload ${CACHE}/Magisk-v26.1.zip
	read
	adb reboot

dump_running:
	adb shell zcat /proc/config.gz > from-${CODENAME}/config
	adb shell su -c cat /proc/cmdline > from-${CODENAME}/cmdline

dump_boot:
	adb shell su -c cat /dev/block/by-name/boot > /tmp/${CODENAME}-boot.img
	pmbootstrap bootimg_analyze /tmp/${CODENAME}-boot.img > from-${CODENAME}/deviceinfo

dumpsys_recovery:
	adb push dumpsys.sh /tmp/dumpsys.sh
	adb shell sh /tmp/dumpsys.sh | tee from-${CODENAME}/dumpsys_recovery

dumpsys_android:
	adb push dumpsys.sh /sdcard/dumpsys.sh
	adb shell 'su -c sh /data/media/dumpsys.sh' > from-${CODENAME}/dumpsys_android

dumpsys_compare:
	grep -A1 -h -r '/sys/devices/platform/goodix_ts.0/driver_info' .

telnet:
	telnet 172.16.42.1
	# vi dumpsys.sh

init:
	pmbootstrap init

checksum:
	pmbootstrap checksum ${DEVICE}
	pmbootstrap checksum ${KERNEL}