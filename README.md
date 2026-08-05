# UCSIHackathon

## secure-email-service

A FastAPI-based secure email service implementing end-to-end signed/encrypted email
with an admin bot for XSS-style challenges.

### Layout
- `main.py` — FastAPI app, routes (`/api/login`, `/api/me`, `/api/emails`, `/api/send`, `/api/root_cert`, `/api/admin_bot`, `/api/password`).
- `db.py` — async DB layer (users, tokens, emails, certificates).
- `util.py` — crypto helpers (key generation, email signing, template rendering).
- `model.py` — Pydantic models.
- `template.jinja2` — HTML email template.
- `admin_bot.py` — headless browser bot that visits a URL with the admin's session.
- `frontend/` — static client.
- `Dockerfile` / `docker-compose.yml` — container setup.
- `init.py` — DB initializer (creates tables, seeds admin user + certs).
- `requirements.txt` — Python deps.

### Run
```bash
docker compose up --build
```

## ctf-work

Capture-the-flag writeups and source archives from picoCTF / CyLab Security Academy
practice challenges solved in this workspace.

- `ctf-work/secretbox/` — SQL Injection challenge ("Secret Box"); `SOP.md` documents the exploit.
- `ctf-work/secretbox/source/` — full source bundle of the challenge.
- `ctf-work/secretbox/SOP.md` — writeup / SOP for the SQLi.

### Try the SQLi locally
See `ctf-work/secretbox/SOP.md` for the full step-by-step.
