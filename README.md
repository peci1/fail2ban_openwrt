# fail2ban_openwrt
OpenWRT support for fail2ban with special additions of support for PPtP banning.

## Installation

If you don't already have fail2ban installed, you can try the `./install_fail2ban.sh` script.
It does its best to install it, but it is still possible you'd have to make some manual steps.
By default, it downloads the sources to `/usr/src/fail2ban`. If you pass the install script
an argument, it will download the sources to that destination instead.

Once fail2ban is installed, run `./install_f2b_config.sh` to install the files necessary for
running fail2ban under OpenWRT. You can enable automatic startup of fail2ban by calling

    /etc/init.d/fail2ban enable
    
### PPtP banning support

To get support for a PPtP server filter that bans users who failed authentication, run
`./install_pptp_support.sh`. Please, consider that it sets the ppp daemon to debug mode
(by editing `/etc/ppp/options.pptpd`). This might result in sensitive information appearing
in the system log. If you don't like this, you'll have to reconfigure your syslog, because
the debug mode is essential for the pptp fail2ban filter to work.

## Usage

Start the fail2ban server with `/etc/init.d/fail2ban start`. It should spawn a fail2ban process
and you should see some output in syslog and possibly also in `/var/log/fail2ban.log`. If
something doesn't work, try running manually `/usr/bin/fail2ban-server -v -xf --logtarget=sysout start`
to see what's the problem.

## Configuration

Fail2ban stores a database of already banned IP addresses. It is best if this file survives
restarts of the router. By default, it is put in `/var/lib/fail2ban/fail2ban.sqlite3`. If your
`/var` directory resides in memory only, you might want to change the config if `/etc/config/fail2ban`
to point to a persistent place. But be aware that if your router's system is on an an eMMC
flash memory, it is possibly not meant to keep often-changing files and you should rather
connect an external drive and set it as the location for fail2ban database.