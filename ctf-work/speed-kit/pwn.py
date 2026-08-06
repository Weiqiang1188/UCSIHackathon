#!/usr/bin/env python3
"""Speed-kit: pwn.  Pre-stage this.  Edit HOST/PORT and run."""
import sys
from pwn import *

HOST = "CHANGEME.picoctf.net"
PORT = 0
BINARY = "./CHANGEME"

def main():
    r = remote(HOST, PORT) if HOST != "CHANGEME.picoctf.net" else process(BINARY)
    # 1) banner
    try:
        banner = r.recv(timeout=2)
        print(banner.decode(errors="replace"), end="")
    except Exception:
        pass

    # 2) auto-`help`
    if hasattr(r, "sendline"):
        r.sendline(b"help")
        try:
            print(r.recv(timeout=2).decode(errors="replace"), end="")
        except Exception:
            pass

    # 3) interactive — you drive from here
    r.interactive()

if __name__ == "__main__":
    main()
