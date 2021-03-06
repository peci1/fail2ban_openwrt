#!/usr/bin/env sh

# Copyright (C) 2020 Martin Pecka, 3-clause BSD license (see LICENSE file)

# Install basic OpenWRT support for fail2ban

SCRIPT_DIR="$(cd "$(dirname "${SCRIPT}")" >/dev/null 2>&1 && pwd)"

mkdir -p /etc/fail2ban/action.d
mkdir -p /etc/fail2ban/fail2ban.d

cp "${SCRIPT_DIR}/etc/config/fail2ban" /etc/config/fail2ban
cp "${SCRIPT_DIR}/etc/fail2ban/action.d/"* /etc/fail2ban/action.d/
cp "${SCRIPT_DIR}/etc/fail2ban/fail2ban.d/uci.conf" /etc/fail2ban/fail2ban.d/
cp "${SCRIPT_DIR}/etc/init.d/fail2ban" /etc/init.d/fail2ban
cp "${SCRIPT_DIR}/etc/firewall.fail2ban" /etc/firewall.fail2ban

# unfortunately, UCI doesn't provide a nice way to add an anonymous section only if it doesn't already exist
if ! uci show firewall | grep -q firewall.fail2ban; then
  name="$(uci add firewall include)"
  uci set "firewall.${name}.path=/etc/firewall.fail2ban"
  uci set "firewall.${name}.enabled=1"
  echo -e "Adding the following UCI config:\n $(uci changes)"
  uci commit
fi
