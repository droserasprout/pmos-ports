PMAPORTS=~/.cache/pmbootstrap/cache_git/pmaports/device/testing/
CACHE=~/.cache
DEVICE=device-xiaomi-tucana
KERNEL=linux-xiaomi-tucana-erikdrozina

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
	pmbootstrap build ${DEVICE}
	pmbootstrap build ${KERNEL} --force

boot:
	pmbootstrap flasher boot

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
	adb shell zcat /proc/config.gz > from_device/config
	adb shell cat /proc/cmdline > from_device/cmdline

init:
	pmbootstrap init