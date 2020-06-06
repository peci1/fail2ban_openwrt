#!/usr/bin/env sh

# Install Fail2Ban from master branch

download_dir="/usr/src"
if [ $# -gt 1 ]; then
  download_dir="$1"
fi

cd "${download_dir}"
git clone https://github.com/fail2ban/fail2ban.git
cd fail2ban
python3 setup.py install 