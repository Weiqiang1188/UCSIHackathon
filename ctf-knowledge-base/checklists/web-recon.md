# Web Challenge Recon Checklist

## Initial Connection
```bash
# Is the server up?
curl -v http://target:port/

# What framework?
whatweb http://target:port/

# Quick port scan
nmap -p- --min-rate=1000 target
```

## Technology Fingerprinting
- [ ] **Server**: Apache, Nginx, Node, Python, Go?
- [ ] **Framework**: Flask, Express, Django, FastAPI, Rails?
- [ ] **Frontend**: React, Vue, Angular, vanilla JS?
- [ ] **Database**: MySQL, PostgreSQL, MongoDB, Redis, SQLite?
- [ ] **Template engine**: Jinja2, EJS, Pug, Twig, Thymeleaf?

## API Discovery
- [ ] Check `/robots.txt`, `/sitemap.xml`
- [ ] Check `/api/`, `/docs`, `/swagger`, `/openapi.json`
- [ ] Check common API paths: `/api/users`, `/api/admin`, `/api/debug`
- [ ] Check for GraphQL: `/graphql`, `/gql`
- [ ] Look at JS source for API endpoints (browser DevTools → Sources)

## Source Code (if provided)
- [ ] `package.json` / `requirements.txt` → library versions (known vulns?)
- [ ] `Dockerfile` / `docker-compose.yml` → internal services exposed?
- [ ] Configuration files → secrets, API keys, database URLs?
- [ ] Test files → test credentials, test endpoints?

## Authentication
- [ ] Try default credentials: `admin:admin`, `admin:password`, `test:test`
- [ ] Try SQLi in login: `admin' --`, `' OR 1=1 --`
- [ ] Try NoSQLi in login: `{"$gt": ""}`
- [ ] Check password reset flow
- [ ] Check if registration is open

## Parameter Discovery
- [ ] Check URL parameters on every page
- [ ] Check hidden form fields (View Source)
- [ ] Check for debug parameters: `?debug=true`, `?source=1`
- [ ] Check for file inclusion: `?file=`, `?page=`, `?template=`
- [ ] Check for redirect: `?url=`, `?redirect=`, `?next=`

## XSS Quick Tests
```html
<script>alert(1)</script>
"><script>alert(1)</script>
'><script>alert(1)</script>
<img src=x onerror=alert(1)>
{{7*7}}  <!-- SSTI test -->
${7*7}   <!-- CSTI test -->
```

## File Upload (if present)
- [ ] What extensions are allowed?
- [ ] Is the check client-side only? (check Network tab)
- [ ] Try double extension: `shell.php.jpg`
- [ ] Try null byte: `shell.php%00.jpg`
- [ ] Try MIME type spoofing: change Content-Type header
- [ ] Try .htaccess upload (Apache): `AddType application/x-httpd-php .jpg`

## Admin Bot (if present)
- [ ] How is the bot triggered?
- [ ] What pages does the bot visit? (check bot source)
- [ ] Where is the flag stored? (localStorage, cookies, DOM?)
- [ ] Can we make the bot visit an external URL? (open redirect?)
- [ ] Is the bot's login automated? Can we CSRF it?

## Special Checks
- [ ] Can we access internal services? (SSRF via URL parameter)
- [ ] Is there a cache we can poison?
- [ ] Can we desync requests? (HTTP request smuggling)
- [ ] Is WebSocket used? Can we inject messages?
- [ ] Are there WASM binaries? (different parsing behavior!)
