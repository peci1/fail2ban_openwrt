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
