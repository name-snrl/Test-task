#!/usr/bin/env bash

useradd -m -p user123 -s "$(which bash)" user321
path=/opt/CustomApp/custom.py

mkdir /opt/CustomApp &> /dev/null
echo \
"#!/usr/bin/env python3

import os
import sys
import time
import signal
import resource as res

file = '/tmp/customServicePIDs'
res.setrlimit(res.RLIMIT_AS, (511 * 1048576, 512 * 1048576))

if len(sys.argv) < 2:
    sys.exit('you must add argument')

elif sys.argv[1] == '--start':
    with open(file, 'a') as f:
        f.write(str(os.getpid()) + '\n')

    while True:
        time.sleep(3)

elif sys.argv[1] == '--stop':
    # In fact, I don't understand what this option is supposed to do.
    pids = []

    if os.path.exists(file):
        with open(file, 'r') as f:
            pids = f.readlines()
        os.remove(file)

    for i in pids:
        try:
            os.kill(int(i), signal.SIGTERM)
        except ProcessLookupError:
            continue

    sys.exit()

else:
    sys.exit('bad argument')" > $path && chmod +x $path

echo \
"[Unit]
Description=I'm just sleeping

[Service]
User=user321
ExecStart=$path --start
Restart=always
MemoryLimit=512M" > /etc/systemd/system/custom.service

systemctl start custom.service
