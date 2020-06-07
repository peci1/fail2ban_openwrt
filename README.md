# fail2ban_openwrt
OpenWRT support for fail2ban with special additions of support for PPtP scan banning (optional).

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
`./install_pptp_support.sh`. Please note that it sets the ppp daemon to debug mode
(by editing `/etc/ppp/options.pptpd`). This might result in sensitive information appearing
in the system log. If you don't like this, you'll have to reconfigure your syslog, because
the debug mode is essential for the pptp fail2ban filter to work.

It also configures syslog to create named pipe `/var/log/ppp` which collects only logs from
`pptpd` and `pppd`. This pipe is then processed by a script installed to OpenWRT as
`fail2ban_pptp` that transforms it into file `/var/log/ppp.login`. This is a concise log of
login attempts (both successful and unsuccessful). These attempts are then given to fail2ban
to extract and ban the attackers.

## Usage

Start the fail2ban server with `/etc/init.d/fail2ban start`. It should spawn a fail2ban process
and you should see some output in syslog and possibly also in `/var/log/fail2ban.log`.

## Configuration

Fail2ban stores a database of already banned IP addresses. It is best if this file survives
restarts of the router. By default, it is put in `/var/lib/fail2ban/fail2ban.sqlite3`. If your
`/var` directory resides in memory only, you might want to change the config in `/etc/config/fail2ban`
to point to a persistent place. But be aware that if your router's system is on an an eMMC
flash memory, it is possibly not meant to keep often-changing files and you should rather
connect an external drive and set it as the location for fail2ban database, otherwise it can destroy
your router. You have been warned.

## Troubleshooting

### Fail2ban

If something doesn't work and the fail2ban daemon doesn't start, try running manually
`/usr/bin/fail2ban-server -v -xf --logtarget=sysout start` to see what the problem is.

### PPtP banning

Watch the contents of `/var/log/ppp` and `/var/log/ppp.login` and connect to the VPN server.
There should be some content in both of these files. In `/var/log/ppp.login`, you should see
something like:

 > OK   pptpd PID: 1234, pppd PID: 1235, IP: 1.2.3.4, prefix: 5 Jun 13:14:15 router

You can also try running

    fail2ban-regex /var/log/ppp.login /etc/fail2ban/filter.d/pptp.conf
    
to see whether the processed PPtP log parses correctly. It should output something like:

    Running tests
    =============
    
    Use   failregex filter file : pptp, basedir: /etc/fail2ban
    Use      datepattern : MON Day 24hour:Minute:Second
    Use         log file : /var/log/ppp.login
    Use         encoding : UTF-8
    
    
    Results
    =======
    
    Failregex: 36 total
    |-  #) [# of hits] regular expression
    |   1) [36] ^FAIL.*IP: <HOST>,.*$
    `-
    
    Ignoreregex: 0 total
    
    Date template hits:
    |- [# of hits] date format
    |  [58] MON Day 24hour:Minute:Second
    `-
    
    Lines: 58 lines, 0 ignored, 36 matched, 22 missed
    [processed in 0.03 sec]
    
    Missed line(s): too many to print.  Use --print-all-missed to print all 22 lines
    
To see statistics of the banning, call

    fail2ban-client status pptp