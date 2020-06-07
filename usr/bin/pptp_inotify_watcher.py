#!/usr/bin/env python
# coding=utf-8

from __future__ import print_function

import pyinotify
import time
from subprocess import Popen, PIPE

last_event_time = time.time()
last_parsed_log = ""


def parse():
    global last_parsed_log
    p = Popen(["/usr/bin/parse_pptp_log.py", "/var/log/ppp"], stdout=PIPE)
    parsed_log = p.stdout.readlines()
    if parsed_log != last_parsed_log:
        print("New ppp.login record")
        with open("/var/log/ppp.login", 'w') as f:
            f.writelines([l.decode('utf-8') for l in parsed_log])
        last_parsed_log = parsed_log
        global last_event_time
        last_event_time = time.time()


class EventHandler(pyinotify.ProcessEvent):
    def process_default(self, event):
        global last_event_time

        if time.time() - last_event_time > 1:
            last_event_time = time.time()
            parse()


handler = EventHandler()
wm = pyinotify.WatchManager()
notifier = pyinotify.Notifier(wm, handler)
wdd = wm.add_watch('/var/log/ppp', pyinotify.ALL_EVENTS, rec=True)

parse()

notifier.loop()
