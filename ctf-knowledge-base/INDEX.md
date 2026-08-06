# CTF Knowledge Base - Master Index

> **Purpose**: Reusable CTF solution patterns, exploit templates, and lessons learned.
> **Usage**: During a competition, edit `INSTRUCTIONS.md` to control which files
>   are loaded as context. Point to specific challenge patterns and templates.

## Directory Structure

```
ctf-knowledge-base/
├── INSTRUCTIONS.md          # ← Edit this during competition to control context
├── INDEX.md                 # ← This file - master index
├── methodology/
│   └── approach.md          # Step-by-step CTF methodology
├── patterns/
│   ├── web-xss.md           # XSS patterns (reflected, stored, DOM, shadow DOM)
│   ├── web-ssti.md          # Server-side template injection
│   ├── web-sqli.md          # SQL injection
│   ├── web-ssrf.md          # SSRF
│   ├── web-deserialization.md
│   ├── web-jwt.md           # JWT attacks
│   ├── web-oauth.md         # OAuth/OIDC misconfigurations
│   ├── web-csrf.md          # CSRF
│   ├── web-file-upload.md   # File upload bypasses
│   ├── web-mime.md          # MIME parsing differentials
│   ├── crypto-padding.md    # Padding oracle
│   ├── crypto-hash.md       # Hash length extension
│   ├── crypto-rsa.md        # RSA attacks
│   ├── rev-anti-debug.md    # Anti-debugging bypasses
│   ├── pwn-stack.md         # Stack buffer overflow
│   ├── pwn-heap.md          # Heap exploitation
│   ├── pwn-format-string.md # Format string
│   └── forensics-carving.md # File carving
├── exploits/
│   ├── template-xss.py      # XSS exploit template
│   ├── template-sqli.py     # SQLi exploit template
│   ├── template-ssti.py     # SSTI exploit template
│   └── template-bot.py      # Admin bot/XSS exfiltration template
├── challenges/
│   ├── picoctf-2024/
│   │   └── secure-email-service/
│   │       ├── solution.md      # Full writeup
│   │       ├── exploit.py       # Working exploit
│   │       └── lessons.md       # What we learned
│   └── TEMPLATE/
│       ├── solution.md
│       ├── exploit.py
│       └── lessons.md
└── checklists/
    ├── web-recon.md         # Web challenge recon checklist
    ├── source-review.md     # Source code review checklist
    └── bot-attacks.md       # Admin bot / XSS exfiltration checklist
```
