################################################################################

PMAPORTS=~/.cache/pmbootstrap/cache_git/pmaports/device
PM=pmbootstrap --details-to-stdout -v

################################################################################

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

# no trailing slash!
BACKUP_PATH=~/pmos_backup

PMOS_HOST=chill.lan

################################################################################

push:
	rm -rf ${PMAPORTS}/testing/${DEVICE}
	# rm -rf ${PMAPORTS}/testing/${KERNEL}
	cp -r ${DEVICE} ${PMAPORTS}/testing
	# cp -r ${KERNEL} ${PMAPORTS}/testing
	make checksum

pull:
	rm -rf ${DEVICE}
	# rm -rf ${KERNEL}
	cp -r ${PMAPORTS}/testing/${DEVICE} .
	# cp -r ${PMAPORTS}/testing/${KERNEL} .

kconfig:
	${PM} kconfig edit
	make pull

build_kernel:
	${PM} build ${KERNEL}

build_kernel_force:
	${PM} build ${KERNEL} --force

build_device:
	${PM} build ${DEVICE}

build_device_force:
	${PM} build ${DEVICE}  --force

boot:
	${PM} flasher boot

sideload_octavia:
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

dump_running:
	adb shell zcat /proc/config.gz > from-${CODENAME}/config
	adb shell su -c cat /proc/cmdline > from-${CODENAME}/cmdline

dump_boot:
	adb shell su -c cat /dev/block/by-name/boot > /tmp/${CODENAME}-boot.img
	${PM} bootimg_analyze /tmp/${CODENAME}-boot.img > from-${CODENAME}/deviceinfo

dumpsys_recovery:
	adb push dumpsys.sh /tmp/dumpsys.sh
	adb shell sh /tmp/dumpsys.sh | tee from-${CODENAME}/dumpsys_recovery

dumpsys_android:
	adb push dumpsys.sh /sdcard/dumpsys.sh
	adb shell 'su -c sh /data/media/dumpsys.sh' > from-${CODENAME}/dumpsys_android

dumpsys_compare:
	grep -A1 -h -r "${DUMPSYS}" .

telnet:
	telnet 172.16.42.1
	# vi dumpsys.sh

checksum:
	${PM} checksum ${DEVICE}
	${PM} checksum ${KERNEL}

grep_ports:
	grep -r ${GREP_PORTS} ${PMAPORTS}

################################################################################

install:
	${PM} install

init:
	${PM} init

zap:
	${PM} zap

update:
	${PM} update

test_deviceinfo:
	make push build_device_force
	sudo env -i /usr/bin/sh -c "chroot /home/droserasprout/.cache/pmbootstrap/chroot_rootfs_xiaomi-tucana /bin/sh -c 'apk fix ${DEVICE}'"

################################################################################

pmos_backup:
	mkdir -p ${BACKUP_PATH}

	ssh user@${PMOS_HOST} "apk info | tee apk_info"
	scp user@${PMOS_HOST}:apk_info ${BACKUP_PATH}/apk_info

	ssh -tt user@${PMOS_HOST} "doas sh -c 'apk add rsync && service waydroid-container stop'"
	rsync -avz --exclude=.cache --exclude=.cargo user@${PMOS_HOST}:/home/user/ ${BACKUP_PATH}/


pmos_restore:
	scp ${BACKUP_PATH}/apk_info user@${PMOS_HOST}:apk_info
	ssh -tt user@${PMOS_HOST} "cat apk_info | xargs doas apk add"
