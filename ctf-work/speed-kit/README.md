# Speed Kit

Pre-made scripts for fast CTF solves. Edit the `CHANGEME` lines and run.

| File | Use for | Edit before running |
|------|---------|---------------------|
| `pwn.py` | `nc HOST PORT` or local binary | `HOST`, `PORT`, `BINARY` |
| `ssh.py` | `ssh user@host -p port` | `HOST`, `PORT`, `USER`, `PASS` |
| `web.py` | HTTP challenge | `URL` |
| `recon.sh` | Any binary — quick triage | `BIN` arg |

## Typical 60-second flow

```bash
# 1) triage the binary
./recon.sh ./binary

# 2) start the right kit
python pwn.py        # or ssh.py / web.py

# 3) drive interactively
# - press 'help' or send 'help\n'
# - look at the output
# - craft payload, send, repeat
```

## Pre-stage checklist (do this BEFORE pinging me)

- [ ] Binary downloaded to `ctf-work/<challenge>/`
- [ ] Source downloaded if available
- [ ] Libc downloaded if separate
- [ ] `HOST` and `PORT` (or SSH creds) in your first message
- [ ] First command to try (usually `help` or `--help`)
