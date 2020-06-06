#!/usr/bin/env python
# coding=utf-8

import re
import sys

MAX_LINES_AFTER_CONNECTION_STARTED = 10
MAX_PID_DIFF = 10

logfile = sys.argv[1]

with open(logfile, "r") as f:
    lines = f.readlines()

connection_started_idxs = list()
i = 0
for line in lines:
    if "control connection started" in line:
        connection_started_idxs.append(i)
    i += 1

for i in connection_started_idxs:
    line = lines[i]
    m = re.search(r'^(.*)pptpd\[([0-9]+)\]: CTRL: Client (.*) control', line)
    if m is None:
        continue
    prefix = m.group(1)
    pptpd_pid = int(m.group(2))
    client = m.group(3)

    pppd_pid = None
    for j in range(i, i + MAX_LINES_AFTER_CONNECTION_STARTED):
        line2 = lines[j]
        m = re.search(r'pppd\[([0-9]+)\]: ', line2)
        if m is None:
            continue
        pid = int(m.group(1))
        if (pid - pptpd_pid) < MAX_PID_DIFF:
            pppd_pid = pid
            break

    if pppd_pid is None:
        continue

    user = None
    for j in range(i, len(lines)):
        line2 = lines[j]
        m = re.search(r'pppd\[{}\]: Peer (.*) failed CHAP authentication'.format(pppd_pid), line2)
        if m is not None:
            user = m.group(1)
            break
        m = re.search(r'pppd\[{}\]: peer from calling number {} authorized'.format(pppd_pid, client), line2)
        if m is not None:
            break

    if user is None:
        print("OK   pptpd PID: {}, pppd PID: {}, IP: {}, prefix: {}".format(
            pptpd_pid, pppd_pid, client, prefix))
    else:
        print("FAIL pptpd PID: {}, pppd PID: {}, IP: {}, user: {}, prefix: {}".format(
            pptpd_pid, pppd_pid, client, user, prefix))