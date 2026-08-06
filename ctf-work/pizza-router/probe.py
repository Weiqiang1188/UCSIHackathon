#!/usr/bin/env python3
"""Probe the pizza router remote service."""
from pwn import *
import sys, io, time
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

context.log_level = "info"

r = remote("mysterious-sea.picoctf.net", 59623)

def send(cmd, wait=0.5):
    print(f"\n>>> {cmd}")
    r.sendline(cmd.encode() if isinstance(cmd, str) else cmd)
    time.sleep(wait)
    try:
        data = r.recv(timeout=1.5).decode(errors="replace")
        print(data, end="")
        return data
    except EOFError:
        print("[EOF]")
        return ""

# Banner
banner = r.recv(timeout=2).decode(errors="replace")
print(banner)

# Try help
send("help")
# Load a map
send("load city1.map")
# Add some orders
send("add_order 5 5")
send("add_order 6 6")
send("add_order 7 7")
# Try dispatch
send("dispatch 1")
send("dispatch 2")
# Try hidden commands
for cmd in ["coupon", "receipt", "replay", "flag", "secret", "menu", "list", "view", "show", "print", "info", "status"]:
    send(cmd, wait=0.3)
# Try reroute
send("reroute 1 0 0")

r.close()
