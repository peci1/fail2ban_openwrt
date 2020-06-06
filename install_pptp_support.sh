#!/usr/bin/env sh

# Install support for banning pptp failed logins

mkdir -p /etc/fail2ban/filter.d
mkdir -p /etc/fail2ban/jail.d

cp etc/cron.d/parse_ppp_for_fail2ban /etc/cron.d/
cp etc/fail2ban/filter.d/pptp.conf /etc/fail2ban/filter.d/
cp etc/fail2ban/jail.d/pptp.conf /etc/fail2ban/jail.d/
cp etc/syslog-ng.d/pptp.conf /etc/syslog-ng.d/
cp usr/bin/parse_pptp_log.py /usr/bin/

chmod +x /usr/bin/parse_pptp_log.py

/etc/init.d/syslog-ng reload
