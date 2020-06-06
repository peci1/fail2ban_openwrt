# fail2ban_openwrt
OpenWRT support for fail2ban with special additions of support for PPtP banning.

## Manual steps

Edit file `/etc/ppp/options.pptpd` and make sure it contains a line saying `debug`. If you find line `#debug`, just remove the `#` sign.