# 5-Minute CTF Speed Protocol

> Read this **before** every challenge. Paste the relevant section to me at the
> start of each new chat so I behave like a speed-runner, not a researcher.

---

## 0. The 5-minute budget — hard rules

| Minute | What you should see me doing |
|--------|------------------------------|
| 0:00–0:30 | Read the challenge, identify category, **paste the matching playbook section** |
| 0:30–1:00 | `nc` / `ssh` in, run `help`, dump version, identify the sink |
| 1:00–2:30 | Write **minimal** exploit (1–3 lines of pwntools), test, iterate |
| 2:30–4:00 | Capture flag, capture it cleanly |
| 4:00–4:30 | Append to playbook (flag at bottom, no fluff) |
| 4:30–5:00 | Push to repo (only if you ask) |

**If minute 3 arrives with no flag, switch to post-mortem mode immediately.**
A 5-min post-mortem beats a 15-min miss.

---

## 1. How to start every new chat (copy-paste this)

```
CTF: <picoCTF / HTB / etc.> — <category> — <title>
Budget: 5 min HARD STOP. Flag at the bottom of the reply.
Playbook: https://github.com/Weiqiang1188/UCSIHackathon/blob/secure-email-service/ctf-work/<relevant>.MD
Apply the matching SOP, do NOT re-read the whole MD.
Skip the long intros — go straight to the exploit.
```

If the category is new (no playbook), just say:
```
New category. Show me the SOP skeleton first (10 sec), then go.
```

---

## 2. What I will *not* do (and what I'll do instead)

| ❌ Don't | ✅ Do instead |
|---------|--------------|
| Re-disassemble 2000 lines of `main()` | `objdump -d binary \| grep -A20 <func_name>` — one targeted dump |
| Write a 200-line exploit on the first try | 3–5 line pwntools snippet, test, extend |
| Ask "should I try X or Y?" | Pick the higher-probability one, run it, tell you the result |
| Re-verify "just to make sure" | Trust the first result unless it's clearly wrong |
| Write a long writeup before capturing the flag | Flag → then writeup, never before |
| Wait for the user to prompt each step | Drive: connect, probe, exploit, capture, in one flow |

---

## 3. Decision tree for the first 60 seconds

```
nc/ssh into target
  │
  ├─ Gets a banner + `help`?
  │     └─ yes → read help, list commands, jump to §4
  │
  ├─ Source file provided?
  │     └─ yes → `grep -nE "strcpy|gets|printf|system|execve|malloc|free|win" <file>`
  │              and jump straight to the vulnerable function
  │
  └─ Binary only, no source?
        └─ `checksec`, then `strings | grep -iE "flag|win|shell|password"`
           then `objdump -d binary | grep -B2 -A5 <interesting_string>`
```

---

## 4. Category-specific speed hacks

### Web (XSS / SQLi / SSRF / auth bypass)
- 30 s: `view-source:`, look at every JS file, every API endpoint
- 1 m: identify the vulnerable param (search the source for `req.query`, `req.body`, `req.params`)
- 2 m: craft the payload **inline in curl/pwntools**, no script
- 1 m: if it's SQLi, try `'` first; if XSS, try `<img src=x onerror=...>` first
- 30 s: capture flag

### Binary / pwn
- 30 s: `file`, `checksec`, `strings | grep -iE "flag|win|/bin/sh"`
- 1 m: `objdump -d binary | grep -B2 -A15 <win_func_or_main>` — only the relevant function
- 1 m: identify the primitive (read/write/what-where), identify the leak, plan the chain
- 1 m: 10-line pwntools exploit, send it
- 1 m: if it fails once, **read the error, fix the one thing, retry once**, then post-mortem

### Crypto
- 30 s: identify the cipher (look at the constants, the block size, the mode)
- 1 m: identify the weakness (ECB repetition? small key? padding oracle? chosen plaintext?)
- 2 m: write the attack in pure Python (no sage unless you need it)
- 1 m: capture flag

### Forensics / OSINT
- 30 s: `file`, `strings`, `exiftool`, `binwalk -e`
- 1 m: if it's an image, `steghide extract` or `zsteg`; if it's a pcap, `tshark -r file -Y 'http'`
- 2 m: follow the breadcrumb (the challenge name is usually a hint)
- 1 m: capture flag

### Reverse
- 30 s: `file`, `strings`, identify the language/framework
- 1 m: `ghidra` headless or `r2 -A binary` (one command, full analysis)
- 2 m: trace the input → vulnerable function → win condition
- 1 m: extract the flag from the binary or replay the algo

---

## 5. Exploit templates (keep these open)

### Pwntools skeleton (pwn)
```python
from pwn import *
r = remote(HOST, PORT)
# r = process("./binary")
# your exploit here (3-5 lines)
r.interactive()
```

### Web one-liner (curl)
```bash
curl -sS "$URL" -X POST -d "param=PAYLOAD" | grep -oE "picoCTF\{[^}]+\}"
```

### SQLi one-liner
```sql
' UNION SELECT 1,2,3-- -
' OR 1=1-- -
```

### Crypto: XOR brute
```python
for k in range(256):  # single-byte XOR
    if all(c in string.printable for c in bytes(b^k for b in ct)):
        print(k, bytes(b^k for b in ct))
```

---

## 6. The "I'm stuck" trigger

If you see me say any of these, **stop me immediately**:

- "Let me try one more thing..."
- "Hmm, let me re-read the disassembly..."
- "I think the approach is..."
- (silence for > 30 s while I think)

Just say: **"POST-MORTEM. 5 MIN. NOW."** and I'll write a lessons-learned
section instead of burning more time.

---

## 7. After every challenge (30-second ritual)

1. Flag captured? → append to the matching playbook MD (flag at bottom)
2. Flag missed?  → append a post-mortem (5-min lessons learned)
3. `git add` + `git commit -m "Add <challenge>"` + `git push`
4. Move to the next challenge

The playbook compounds. After 10 challenges, you'll have a 50-page
reference that covers most of what you'll see in a competition.

---

## 8. What *you* (the user) can do to speed me up

- **Pre-stage the SSH/NC command** in your first message (host, port, password)
- **Pre-stage the source files** if available
- **Time-stamp your prompts**: "5 min budget, GO"
- **Interrupt early**: don't wait for me to give up — pull the plug at minute 3
- **Run tools in parallel** if you can (download the binary while I read the description)
- **Be the "type checker"**: I'll write pwntools, you spot the typo

---

## 9. The single most important rule

> **The flag is the only thing that matters. The writeup is a side effect.**

If I have to choose between capturing the flag and writing a beautiful
explanation, I capture the flag. The writeup can come after, or never —
the flag is the score.

---

## 10. Quick reference: my checklist before I say "done"

- [ ] Did I capture a flag that matches the format `picoCTF{...}` or similar?
- [ ] Did I verify the flag is *the* flag (not a fake/partial)?
- [ ] Did I put the flag at the *bottom* of the reply?
- [ ] Did I keep the reply short (no 500-line writeup before the flag)?
- [ ] Did I tell you what the category was, in case the playbook needs updating?
- [ ] Did I update the playbook if I learned something new?

If any of these is "no", I'm not done.
