#!/usr/bin/env sh

# Copyright (C) 2020 Martin Pecka, 3-clause BSD license (see LICENSE file)

# Install Fail2Ban from master branch

set -e

SCRIPT_DIR="$(cd "$(dirname "${SCRIPT}")" >/dev/null 2>&1 && pwd)"
. "${SCRIPT_DIR}/detect_python.sh"

download_dir="/usr/src"
if [ $# -gt 0 ]; then
  download_dir="$1"
fi

opkg update
opkg install git
opkg install git-http

# if inotify is available through opkg and is not installed, install it
if opkg info libinotifytools | grep -q "not-installed"; then
  # make sure we have pip
  if [ "${python_ver}" -eq 3 ]; then
    opkg install python3-pip
  else
    opkg install python-pip
  fi
  
  opkg install libinotifytools
  /usr/bin/env "${python_prog}" -m pip install pyinotify
fi

mkdir -p "${download_dir}"
cd "${download_dir}"
git clone https://github.com/fail2ban/fail2ban.git
cd fail2ban

if [ "${python_ver}" -eq 3 ]; then
  opkg install python3-lib2to3
  /usr/bin/env "${python_prog}" "${SCRIPT_DIR}/2to3" -w --no-diffs bin/* fail2ban
fi

/usr/bin/env "${python_prog}" setup.py install 