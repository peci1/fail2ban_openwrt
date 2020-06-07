# Copyright (C) 2020 Martin Pecka, 3-clause BSD license (see LICENSE file)

python_ver_str="`/usr/bin/env python --version`"
if [ $? ]; then
  python_prog=python3
  python_ver=3
else
  python_prog=python
  case "${python_ver_str}" in
    "Python 3"*) python_ver=3;;
    "Python 2"*) python_ver=2;;
  esac
fi