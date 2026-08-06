# Source Code Review Checklist

## Phase 1: Reconnaissance (Quick Scan)

### Framework & Language
- [ ] Language: _______________
- [ ] Framework: _______________
- [ ] Template engine: _______________
- [ ] Database: _______________
- [ ] Key libraries (note unusual ones): _______________

### Entry Points
- [ ] List ALL routes/endpoints with HTTP methods
- [ ] List ALL files that handle user input
- [ ] List ALL places where data is stored

## Phase 2: Authentication & Authorization

### Authentication
- [ ] How are users authenticated? (JWT, session, token, basic auth?)
- [ ] Can we register new users?
- [ ] Are there default/guest credentials?
- [ ] Is there a "forgot password" flow?
- [ ] Are tokens predictable or forgeable?

### Authorization
- [ ] Are admin endpoints properly protected?
- [ ] Can a regular user access admin functionality?
- [ ] Is there IDOR (Insecure Direct Object Reference)?
- [ ] Can we enumerate users?

## Phase 3: Input Vectors

### URL Parameters
- [ ] Are URL parameters reflected in the response?
- [ ] Are they used in database queries?
- [ ] Are they used in file operations?
- [ ] Are they used in redirects?

### POST Body
- [ ] What fields are accepted?
- [ ] Is there server-side validation?
- [ ] Can we send unexpected data types?

### HTTP Headers
- [ ] Is any header value reflected or processed?
- [ ] Is there a `X-Forwarded-For` or `Host` header injection?

### File Upload
- [ ] What file types are allowed?
- [ ] How is the file type validated? (extension, MIME, magic bytes?)
- [ ] Where are files stored?
- [ ] Can we control the filename/path?

## Phase 4: Output Sinks (User Input → Dangerous Function)

### HTML Context
- [ ] `innerHTML` / `insertAdjacentHTML` / `document.write()` with user input?
- [ ] Template engine: is `autoescape` enabled?
- [ ] Are there any `| safe` or `| raw` filters?
- [ ] Is user input in an HTML attribute? `<div attr="{{input}}">`?

### JavaScript Context
- [ ] `eval()` with user input?
- [ ] `Function()` constructor with user input?
- [ ] `setTimeout()` / `setInterval()` with string argument?
- [ ] User input inside `<script>` tags?

### SQL Context
- [ ] Is user input concatenated into SQL strings?
- [ ] Is an ORM used properly? (check for raw SQL)

### Shell/Command Context
- [ ] `exec()`, `system()`, `popen()`, `subprocess()` with user input?
- [ ] `os.system()` with user-controlled arguments?

### File System Context
- [ ] `open()` with user-controlled path?
- [ ] `os.path.join()` with `../` possible?
- [ ] `zipfile.extractall()` (Zip Slip)?

### Deserialization
- [ ] `pickle.loads()`?
- [ ] `yaml.load()` (unsafe version)?
- [ ] `json.loads()` is SAFE (but check what happens to the parsed data)

### Email/Headers
- [ ] User input in email headers? (CRLF injection)
- [ ] User input in email body?

## Phase 5: Cryptographic Checks

- [ ] Are keys generated with sufficient entropy?
- [ ] Are nonces/IVs reused?
- [ ] Is ECB mode used?
- [ ] Are there padding oracle opportunities?
- [ ] Are signatures properly verified?
- [ ] Check certificate validation (path length, expiration, etc.)

## Phase 6: Business Logic

- [ ] Can we skip payment/verification steps?
- [ ] Can we modify order quantities/amounts?
- [ ] Are there race conditions? (concurrent requests)
- [ ] Can we abuse the "reply" or "forward" functionality?
- [ ] Is there a way to make the system send data to us?

## Phase 7: Unusual Attack Surface

- [ ] WASM binaries? (different parsing behavior)
- [ ] Web Workers? (separate execution context)
- [ ] Service Workers? (request interception)
- [ ] Shadow DOM? (doesn't prevent XSS - scripts access window)
- [ ] Admin bot? (XSS + localStorage exfiltration)
- [ ] WebSockets? (injection in messages)
- [ ] GraphQL? (introspection, batching attacks)

## Quick Wins (Check First!)

1. [ ] `/api/debug` or `/debug` or `/.env` accessible?
2. [ ] `/api/password` returns credentials? (like this challenge!)
3. [ ] Source maps exposed? (`.js.map` files)
4. [ ] `.git` directory exposed?
5. [ ] API documentation exposed? (`/docs`, `/swagger`, `/openapi.json`)
6. [ ] Error messages leak information?
7. [ ] Default credentials? (`admin:admin`, `test:test`)
