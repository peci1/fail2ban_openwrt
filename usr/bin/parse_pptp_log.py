#!/usr/bin/env python
# coding=utf-8

# Copyright (C) 2020 Martin Pecka, 3-clause BSD license (see LICENSE file)

# This program parses the joint log of pppd and pptpd and transforms it into a list
# of connections with either successful or unsuccessful authentication.
# The program requsires pppd logging in debug mode.

# Example of the sequence of lines this program seeks for:
# Jun  5 08:57:02 turris pptpd[16567]: CTRL: Client 92.63.194.26 control connection started
# ...
# Jun  5 08:57:02 turris pppd[16568]: Plugin /usr/lib/pptpd/pptpd-logwtmp.so loaded.
# ...
# Jun  5 08:57:02 turris pppd[16568]: Peer guest failed CHAP authentication

from __future__ import print_function

import os
import re
import signal
import sys
import time


def signal_handler(_, __):
    global interrupted
    interrupted = True


interrupted = False
signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)

# Max number of consecutive lines in the log between the "control connection started"
# line and the line with authentication result.
MAX_LINES_AFTER_CONNECTION_STARTED = 50

# The pptpd process launches a pppd process, but there is no explicitly mentioned
# relation between the PIDs of these processes. We just assume that consecutive lines
# belong together. This could, however, be wrong in some cases, so we check the values
# of the PIDs and if they differ by more than this limit, we assume something unexpected
# happened and the PIDs do not refer to the related processes.
MAX_PID_DIFF = 10

# Name of the pptpd process in log
PPTPD_NAME = "pptpd"
# Name of the pppd process in log
PPPD_NAME = "pppd"

# Name of the log file to parse (should be a pipe)
logfile = sys.argv[1]

if len(sys.argv) > 2:
    PPTPD_NAME = sys.argv[2]
if len(sys.argv) > 3:
    PPPD_NAME = sys.argv[3]

linenum = -1
connection_started_idx = None
prefix = None
pptpd_pid = None
pppd_pid = None
client = None
user = None

while not interrupted:
    if not os.path.exists(logfile):
        print("Logfile {} does not exist. Make sure syslog is correctly configured. "
              "Retrying in 10 seconds".format(logfile), file=sys.stderr)
        time.sleep(10)
        continue
    with open(logfile) as fifo:
        while not interrupted:
            for logline in fifo:
                if len(logline) == 0:
                    break  # fifo writer closed

                linenum += 1

                if connection_started_idx is not None and \
                        (linenum - connection_started_idx) > MAX_LINES_AFTER_CONNECTION_STARTED:
                    connection_started_idx = None
                    prefix = None
                    pptpd_pid = None
                    pppd_pid = None
                    client = None
                    user = None

                if connection_started_idx is None:
                    m = re.search(r'^(.*){}\[([0-9]+)]: CTRL: Client (.*) control connection started'.format(PPTPD_NAME), logline)
                    if m is not None:
                        connection_started_idx = linenum
                        prefix = m.group(1)
                        pptpd_pid = int(m.group(2))
                        client = m.group(3)
                        pppd_pid = None
                        continue

                if connection_started_idx is not None and pptpd_pid is not None and pppd_pid is None:
                    m = re.search(r'{}\[([0-9]+)]: '.format(PPPD_NAME), logline)
                    if m is not None and\
                            (linenum - connection_started_idx) <= MAX_LINES_AFTER_CONNECTION_STARTED:
                        pid = int(m.group(1))
                        if (pid - pptpd_pid) < MAX_PID_DIFF:
                            pppd_pid = pid
                            continue

                if pptpd_pid is not None and pppd_pid is not None:
                    found = False
                    m = re.search(r'{}\[{}]: Peer (.*) failed CHAP authentication'.format(PPPD_NAME, pppd_pid), logline)
                    if m is not None:
                        user = m.group(1)
                        print("FAIL pptpd PID: {}, pppd PID: {}, IP: {}, user: {}, prefix: {}".format(
                            pptpd_pid, pppd_pid, client, user, prefix))
                        found = True
                    if not found:
                        m = re.search(r'{}\[{}]: peer from calling number {} authorized'.format(PPPD_NAME, pppd_pid, client), logline)
                        if m is not None:
                            print("OK   pptpd PID: {}, pppd PID: {}, IP: {}, prefix: {}".format(
                                pptpd_pid, pppd_pid, client, prefix))
                            found = True
                    if found:
                        connection_started_idx = None
                        prefix = None
                        pptpd_pid = None
                        pppd_pid = None
                        client = None
                        user = None
