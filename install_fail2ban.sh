#!/usr/bin/env sh

# Install Fail2Ban from master branch

set -e

download_dir="/usr/src"
if [ $# -gt 1 ]; then
  download_dir="$1"
fi

opkg update
opkg install git
opkg install git-http
opkg install python3-lib2to3

if [ ! -f /usr/bin/2to3 ]; then
  cp usr/bin/2to3 /usr/bin/
  chmod +x /usr/bin/2to3
fi

mkdir -p "${download_dir}"
cd "${download_dir}"
git clone https://github.com/fail2ban/fail2ban.git
cd fail2ban
python3 fail2ban-2to3
python3 setup.py install 