.PHONY: $(MAKECMDGOALS)
MAKEFLAGS += --no-print-directory
##
##  🚧 pmOS scripts (host)
##

BACKUP_PATH=~/pmos_backup

PMOS_HOST=chill.lan
PMOS_USER=droserasprout
PMOS_SSH=ssh -tt ${PMOS_USER}@${PMOS_HOST}

##

help:               ## Show this help (default)
	@grep -Fh "##" $(MAKEFILE_LIST) | grep -Fv grep -F | sed -e 's/\\$$//' | sed -e 's/##//'

setup:              ## Prepare pmOS device for running scripts
	mkdir -p ${BACKUP_PATH}
	scp Makefile.device ${PMOS_USER}@${PMOS_HOST}:Makefile
	${PMOS_SSH} "make setup"

##

backup:             ## Backup pmOS device
	make backup_apk
	make backup_home
	make backup_waydroid

restore:            ## Restore pmOS device
	make restore_apk
	make restore_home
	make restore_waydroid

##

backup_apk:         ##
	${PMOS_SSH} "apk info | tee apk_info"
	scp ${PMOS_USER}@${PMOS_HOST}:apk_info ${BACKUP_PATH}/apk_info

restore_apk:        ##
	scp ${BACKUP_PATH}/apk_info ${PMOS_USER}@${PMOS_HOST}:apk_info
	${PMOS_SSH} "cat apk_info | xargs doas apk add"

backup_home:        ##
	rsync -avz --exclude=.cache --exclude=.cargo ${PMOS_USER}@${PMOS_HOST}:/home/${PMOS_USER}/ ${BACKUP_PATH}/

restore_home:       ##
	rsync -avz --exclude=.cache --exclude=.cargo ${BACKUP_PATH}/ ${PMOS_USER}@${PMOS_HOST}:/home/${PMOS_USER}/

backup_waydroid:    ##
	${PMOS_SSH} "make backup_waydroid"

	scp ${PMOS_USER}@${PMOS_HOST}:waydroid_data.tar.zst ${BACKUP_PATH}/waydroid_data.tar.zst

restore_waydroid:   ##
	scp ${BACKUP_PATH}/waydroid_data.tar.zst ${PMOS_USER}@${PMOS_HOST}:waydroid_data.tar.zst

	${PMOS_SSH} "make restore_waydroid"

##