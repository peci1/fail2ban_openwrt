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

# if only python3 is available, change the shebang accordingly
. detect_python.sh
if [ "${python_prog}" = "python3" ]; then
  sed -i '1s=^#! ?/usr/bin/\(python\|env python\)2?=#!%{__python3}=' /usr/bin/parse_pptp_log.py
fi

/etc/init.d/syslog-ng reload
