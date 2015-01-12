PKG_NAME = gaspSync
PKG_VERS = 0.0.2-RC1
PKG_EXT = zip
PKG_DIST_NAME = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = https://github.com/vinpel/gaspSync/releases/download/$(PKG_VERS)
PKG_DIR = 

DEPENDS =

HOMEPAGE = http://githup.com/vinpel
COMMENT  = gasp.
LICENSE  = BSD

CONFIGURE_TARGET = nop
COMPILE_TARGET = nop
INSTALL_TARGET = myInstall

include ../../mk/spksrc.cross-cc.mk

.PHONY: myInstall
myInstall:
	mkdir -p $(STAGING_INSTALL_PREFIX)/share/gaspSync
	composer update --working-dir $(WORK_DIR)/
	tar -cf - -C $(WORK_DIR)/$(PKG_DIR) . --exclude install | tar -xf - -C $(STAGING_INSTALL_PREFIX)/share/gaspSync


	
