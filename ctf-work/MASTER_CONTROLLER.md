# ⚡ CyLab CTF Master Controller — 1-Minute Turbo Mode

> **PURPOSE**: Ultra-fast execution protocol for CyLab CTF challenges.
> **TARGET**: **< 60 seconds to flag**. Zero pre-flight file reads. Zero fluff.

---

## ⚡ 1. Why We Switched to 1-Minute Turbo Mode
- **Problem**: Reading multiple `.md` files (`MASTER_CONTROLLER.md`, `WEB_PLAYBOOK.md`, `INDEX.md`, etc.) before starting added 4-5 unnecessary tool calls (~3–4 minutes of overhead).
- **Solution**: All core attack vectors are inlined directly into `AGENTS.md` and `CLAUDE.md`. The agent executes the first command in **Turn 1** without reading external files first.

---

## ⏱️ 2. 60-Second Execution SLA

- **0:00 – 0:15**: Fire target probe command immediately (checksec / strings / curl / SQLi test).
- **0:15 – 0:45**: Execute minimal inline exploit payload.
- **0:45 – 1:00**: Extract & display flag in clean copy-paste block.


---

## 🚀 3. Quick Reference Cheatsheets
- **Web**: SQLi (`' OR 1=1-- -`), Cmd Injection (`$(cat /flag*)`), LFI (`../../../../flag.txt`).
- **Binary/Pwn**: `checksec`, `strings <bin> | grep flag`, disasm `win()`.
- **Crypto**: Double-Base64 decode -> Caesar/ROT shift brute force (`picoCTF{` / `flag{`).

