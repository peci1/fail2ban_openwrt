#!/usr/bin/env sh

# Install basic OpenWRT support for fail2ban

mkdir -p /etc/fail2ban/action.d
mkdir -p /etc/fail2ban/fail2ban.d

cp etc/config/fail2ban /etc/config/fail2ban
cp etc/action.d/* /etc/fail2ban/action.d/
cp etc/fail2ban.d/uci.conf /etc/fail2ban/fail2ban.d/
cp etc/init.d/fail2ban /etc/init.d/fail2ban
