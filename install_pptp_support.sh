#!/usr/bin/env sh

# Copyright (C) 2020 Martin Pecka, 3-clause BSD license (see LICENSE file)

# Install support for banning pptp failed logins

SCRIPT_DIR="$(cd "$(dirname "${SCRIPT}")" >/dev/null 2>&1 && pwd)"

mkdir -p /etc/fail2ban/filter.d
mkdir -p /etc/fail2ban/jail.d

cp "${SCRIPT_DIR}/etc/init.d/fail2ban_pptp" /etc/init.d/
cp "${SCRIPT_DIR}/etc/fail2ban/filter.d/pptp.conf" /etc/fail2ban/filter.d/
cp "${SCRIPT_DIR}/etc/fail2ban/jail.d/pptp.conf" /etc/fail2ban/jail.d/
cp "${SCRIPT_DIR}/etc/syslog-ng.d/pptp.conf" /etc/syslog-ng.d/
cp "${SCRIPT_DIR}/usr/bin/parse_pptp_log.py" /usr/bin/

chmod +x /usr/bin/parse_pptp_log.py

# if only python3 is available, change the shebang accordingly
. "${SCRIPT_DIR}/detect_python.sh"
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