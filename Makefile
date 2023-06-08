PMAPORTS=~/.cache/pmbootstrap/cache_git/pmaports/device/testing/
CACHE=~/.cache
KERNEL=linux-xiaomi-tucana-ericdrozina

push:
	rm -r ${PMAPORTS}/${KERNEL}
	cp -r ${KERNEL} ${PMAPORTS}
	pmbootstrap checksum ${KERNEL}

pull:
	rm -r ${KERNEL}
	cp -r ${PMAPORTS}/${KERNEL} .

kconfig:
	pmbootstrap kconfig edit
	make pull

build:
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

dump_config:
	adb shell zcat /proc/config.gz > configs/device