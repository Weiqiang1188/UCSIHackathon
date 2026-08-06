#!/usr/bin/env python3
"""teacash — free-list traversal.
glibc 2.27 tcache. Chunks freed 5..0 → LIFO chain: 0→1→2→3→4→5→NULL.
Program prints head (=chunks[0]) and asks for 6 chunk addresses in chain order.
We compute chunks[i] = head + i*0x90 (header 0x10 + payload 0x80)."""
import sys, re
sys.path.insert(0, r'C:\Users\weiqi\AppData\Local\Programs\Python\Python312\Lib\site-packages')
from pwn import *
context.log_level = 'info'

CHUNK_USER_SIZE = 0x80
CHUNK_STEP      = CHUNK_USER_SIZE + 0x10   # 0x90 between successive user ptrs

p = remote('candy-mountain.picoctf.net', 63632)
p.recvuntil(b'-> ')
head_line = p.recvline().strip().decode()
head = int(head_line, 16)
log.success('head = chunks[0] = %#x', head)

for i in range(6):
    addr = head + i * CHUNK_STEP
    p.recvuntil(b'address: ')
    log.info('sending chunks[%d] = %#x', i, addr)
    p.sendline(hex(addr).encode())

data = p.recvall(timeout=5).decode(errors='replace')
print('=' * 60)
print(data)
m = re.search(r'(picoCTF\{[^}]+\}|flag\{[^}]+\})', data)
if m:
    print('=' * 60)
    print(m.group(1))
