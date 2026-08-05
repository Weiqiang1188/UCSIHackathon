#!/usr/bin/env python3
"""Speed-kit: ssh.  Pre-stage this.  Edit creds and run."""
import sys
import paramiko

HOST = "CHANGEME.picoctf.net"
PORT = 0
USER = "ctf-player"
PASS = "CHANGEME"

def run(c, cmd, wait=0.5):
    print(f"\n$ {cmd}")
    si, so, se = c.exec_command(cmd, timeout=10)
    out = so.read().decode(errors="replace")
    err = se.read().decode(errors="replace")
    if out: print(out, end="")
    if err: print(f"[stderr] {err}", end="")
    return out

def main():
    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    c.connect(HOST, PORT, USER, PASS, timeout=15)
    print(f"[OK] {USER}@{HOST}:{PORT}")
    run(c, "id; pwd; ls -la")
    run(c, "help 2>&1 || ./CHANGEME --help 2>&1 || true")
    c.close()

if __name__ == "__main__":
    main()
