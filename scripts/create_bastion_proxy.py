#!/usr/bin/python3

import sys
import os
import json
import socketserver
import subprocess
import platform
import time
import socket
import shlex
import struct

if (hasattr(os, "devnull")):
   REDIRECT_TO = os.devnull
else:
   REDIRECT_TO = "/dev/null"

def free_port():
    tcp = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    tcp.setsockopt(socket.SOL_SOCKET, socket.SO_LINGER, struct.pack('ii', 1, 0))
    tcp.bind(('', 0))
    addr, port = tcp.getsockname()
    time.sleep(1)
    tcp.close()
    time.sleep(3)
    return port

def close_std():
    i = os.open(REDIRECT_TO, os.O_CREAT|os.O_APPEND|os.O_RDONLY) # stdin
    os.dup2(i, 0)
    out = os.open(REDIRECT_TO, os.O_CREAT|os.O_APPEND|os.O_RDWR)   # stdout
    os.dup2(out, 1)
    er = os.open(REDIRECT_TO, os.O_CREAT|os.O_APPEND|os.O_RDWR)   # stderr
    os.dup2(er, 2)


def start_proxy(data, port):
    os.setsid()
    close_std()
    if (os.fork() == 0):
        os.chdir("/")
        os.umask(0)
        args = shlex.split('gcloud compute ssh  %(instance)s --tunnel-through-iap --project %(project)s --zone %(zone)s  -- -4fN  -L %(port)s:localhost:8888' % {
            'instance': data['instance'],
            'project': data['project'],
            'zone': data['zone'],
            'port': port
        })
        os.execvp(args[0], args[0:])
        sys.exit(3) # unreachable

def start_timer(pid):
    close_std()
    time.sleep(1800)
    os.kill(pid, 9)
    os._exit(0)

content = sys.stdin.read()
data = json.loads(content)
port = free_port()
sys.stdout.write('{"port":"%(port)s"}\n' % {'port': port})
sys.stdout.flush()
pid = os.fork()
if (pid == 0):
    start_proxy(data, port)

if (os.fork() == 0):
    start_timer(pid)

time.sleep(10)
os._exit(0)
