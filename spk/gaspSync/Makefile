SPK_NAME = gaspSync
SPK_VERS = 0.0.2-RC2
#SPK_REV = 1
SPK_ICON = src/gaspSync.png
DSM_UI_DIR = app

DEPENDS  = cross/$(SPK_NAME)

MAINTAINER = SynoCommunity
DESCRIPTION = gaspSync test package
DESCRIPTION_FRE = PHP self hosted Sync-1.5 Server
ADMIN_URL = /
ADMIN_PORT = 4000
RELOAD_UI = yes
DISPLAY_NAME = gaspSync
CHANGELOG = "Initiale version"

HOMEPAGE   = http://github.com/vinpel/gaspSync
LICENSE    = BSD

WIZARDS_DIR = src/wizard/

INSTALLER_SCRIPT = src/installer.sh
SSS_SCRIPT       = src/dsm-control.sh

INSTALL_DEP_SERVICES = apache-web
START_DEP_SERVICES = apache-web
INSTUNINST_RESTART_SERVICES = apache-web

INSTALL_PREFIX = /usr/local/$(SPK_NAME)

POST_STRIP_TARGET = gaspSync_extra_install

# Pure PHP package, make sure ARCH is not defined
override ARCH=

include ../../mk/spksrc.spk.mk

.PHONY: gaspSync_extra_install
gaspSync_extra_install:
	# creation de l'arborescence de base
	install -m 755 -d $(STAGING_DIR)/app
	#copy of config file
	install -m 666 src/init.synology.virtualhost.conf $(STAGING_DIR)/init.synology.virtualhost.conf
	install -m 666 src/init.synology.init.php $(STAGING_DIR)/init.synology.init.php
	install -m 755 -d $(STAGING_DIR)/app/images
	for size in 16 24 32 48 72; do \
		convert $(SPK_ICON) -thumbnail $${size}x$${size} \
		        $(STAGING_DIR)/app/images/$(SPK_NAME)-$${size}.png ; \
	done
