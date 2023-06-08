PMAPORT=~/.cache/pmbootstrap/cache_git/pmaports/device/testing/linux-xiaomi-tucana
CACHE=~/.cache

push:
	cp configs/current ${PMAPORT}/config-xiaomi-tucana.aarch64
	cp APKBUILD ${PMAPORT}/APKBUILD
	pmbootstrap checksum linux-xiaomi-tucana

pull:
	cp ${PMAPORT}/config-xiaomi-tucana.aarch64 configs/current
	cp ${PMAPORT}/APKBUILD APKBUILD

kconfig:
	pmbootstrap kconfig edit
	make pull

build:
	pmbootstrap build linux-xiaomi-tucana --force

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