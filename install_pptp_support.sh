#!/usr/bin/env sh

# Install support for banning pptp failed logins

mkdir -p /etc/fail2ban/filter.d
mkdir -p /etc/fail2ban/jail.d

cp etc/init.d/fail2ban_pptp /etc/init.d/
cp etc/fail2ban/filter.d/pptp.conf /etc/fail2ban/filter.d/
cp etc/fail2ban/jail.d/pptp.conf /etc/fail2ban/jail.d/
cp etc/syslog-ng.d/pptp.conf /etc/syslog-ng.d/
cp usr/bin/parse_pptp_log.py /usr/bin/

chmod +x /usr/bin/parse_pptp_log.py

# if only python3 is available, change the shebang accordingly
. ./detect_python.sh
if [ "${python_prog}" = "python3" ]; then
  sed -i '1s=^#! ?/usr/bin/\(python\|env python\)2?=#!%{__python3}=' /usr/bin/parse_pptp_log.py
fi

# set pppd to debug mode (needed for correct log parsing)
if grep -q '^#debug$' /etc/ppp/options.pptpd; then
  sed -i '1s=^#debug=debug=' /etc/ppp/options.pptpd
elif ! grep -q '^debug$' /etc/ppp/options.pptpd; then
  echo "debug" >> /etc/ppp/options.pptpd
fi

/etc/init.d/syslog-ng reload

/etc/init.d/fail2ban_pptp enable
/etc/init.d/fail2ban_pptp start