#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fail2ban
PKG_VERSION:=0.11.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/fail2ban/fail2ban
PKG_MIRROR_HASH:=383108e5f8644cefb288537950923b7520f642e7e114efb843f6e7ea9268b1e0

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Gerald Kerma <gandalf@gk2.net>

include $(TOPDIR)/feeds/packages/lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk

define Package/fail2ban
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Fail2Ban: ban hosts that cause multiple authentication errors
	URL:=https://www.fail2ban.org/
	DEPENDS:=+python3 +python3-dns +libinotifytools
endef

define Package/fail2ban/description
Fail2Ban scans log files like /var/log/auth.log and bans IP addresses conducting too many failed login attempts.
endef

define Package/fail2ban/conffiles
endef

define Package/fail2ban/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/fail2ban.init $(1)/etc/init.d/fail2ban
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_BIN) ./files/etc/config/fail2ban $(1)/etc/config/fail2ban
	$(INSTALL_DIR) $(1)/etc/fail2ban/action.d
	$(INSTALL_BIN) ./files/etc/fail2ban/action.d/* $(1)/etc/fail2ban/action.d/
	$(INSTALL_DIR) $(1)/etc/fail2ban/fail2ban.d
	$(INSTALL_BIN) ./files/etc/fail2ban/fail2ban.d/uci.conf $(1)/etc/init.d/fail2ban/uci.conf
endef

$(eval $(call Py3Package,fail2ban))
$(eval $(call BuildPackage,fail2ban))
