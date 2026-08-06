#!/usr/bin/env python3
"""Hash-only recon: SSH in, list dir, run the binary."""
import paramiko, sys, io

# Force UTF-8 on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

HOST = "rescued-float.picoctf.net"
PORT = 60715
USER = "ctf-player"
PASS = "a630e1f8"

def run(client, cmd, timeout=10):
    print(f"\n$ {cmd}")
    stdin, stdout, stderr = client.exec_command(cmd, timeout=timeout)
    out = stdout.read().decode(errors="replace")
    err = stderr.read().decode(errors="replace")
    if out: sys.stdout.write(out); sys.stdout.write("\n" if not out.endswith("\n") else "")
    if err: sys.stdout.write("[stderr] " + err); sys.stdout.write("\n" if not err.endswith("\n") else "")
    return out, err

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect(HOST, PORT, USER, PASS, timeout=15)
print(f"[OK] Connected as {USER}@{HOST}:{PORT}")

run(c, "id; uname -a; pwd; ls -la")
run(c, "file flaghasher; ls -la flaghasher; stat flaghasher")
run(c, "ls -la /; find / -maxdepth 3 -name 'flag*' 2>/dev/null | head -20")
run(c, "./flaghasher 2>&1 | head -20")
c.close()
