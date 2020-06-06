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

mkdir -p "${download_dir}"
cd "${download_dir}"
git clone https://github.com/fail2ban/fail2ban.git
cd fail2ban

. ./detect_python.sh
if [ "${python_ver}" -eq 3 ]; then
  opkg install python3-lib2to3
  
  if [ ! -f /usr/bin/2to3 ]; then
    cp usr/bin/2to3 /usr/bin/
    chmod +x /usr/bin/2to3
  fi
  2to3 -w --no-diffs bin/* fail2ban
fi

/usr/bin/env "${python_prog}" setup.py install 