# CTF Methodology: Systematic Approach

## Phase 1: Triage (5 minutes)

### 1.1 Identify the Challenge
- [ ] Read the challenge name and hint carefully
- [ ] Identify the category (web, crypto, pwn, rev, forensics, misc)
- [ ] Note any unusual technologies mentioned

### 1.2 Map the Attack Surface
- [ ] If source provided: list all files, note the language and framework
- [ ] If remote only: run initial probes (nmap, curl, whatweb)
- [ ] Identify all endpoints, parameters, and data flows

### 1.3 Find the Flag Location
- [ ] Is the flag in a file on the server?
- [ ] Is it in a database?
- [ ] Is it in an environment variable?
- [ ] Is it in localStorage/cookies (admin bot)?
- [ ] Is it computed from inputs (crypto)?

## Phase 2: Deep Analysis (15-30 minutes)

### 2.1 Source Code Review (if available)
- [ ] Start from main() / entry point
- [ ] Map all routes/endpoints
- [ ] Identify authentication and authorization
- [ ] Find all user-controlled inputs
- [ ] Trace each input to its sink (where it's used)

### 2.2 Data Flow Analysis
For each user input, trace:
```
INPUT → VALIDATION → PROCESSING → STORAGE → RETRIEVAL → OUTPUT
```
- [ ] Is the input validated? How?
- [ ] Is it sanitized/escaped before output?
- [ ] What context is it output into? (HTML, JS, SQL, shell, etc.)

### 2.3 Trust Boundary Mapping
- [ ] Who can access what?
- [ ] Where does trust change? (e.g., admin vs. user)
- [ ] Is there privilege escalation possible?

## Phase 3: Vulnerability Hunting

### 3.1 Systematic Check by Sink
For each output context, check:
| Context | Attack | Check |
|---------|--------|-------|
| HTML body | XSS | Is user input in innerHTML? |
| HTML attribute | XSS | Are quotes escaped? |
| JavaScript | XSS | Is user input in <script> or event handlers? |
| SQL query | SQLi | Is input concatenated? |
| Shell command | RCE | Is user input in exec/system? |
| File path | Path traversal | Is input used in file operations? |
| Template | SSTI | Is user input rendered as template? |
| Deserialization | RCE | Is pickle/unserialize used? |
| Redirect | Open redirect | Is user input in Location header? |
| Email/Headers | Injection | Is user input in email headers? |

### 3.2 Check for Common Vulnerability Patterns
- [ ] Missing authentication checks
- [ ] Hardcoded secrets
- [ ] Insecure defaults
- [ ] Race conditions (TOCTOU)
- [ ] Integer overflow
- [ ] Type confusion
- [ ] Parser differentials

## Phase 4: Exploitation

### 4.1 Build Proof of Concept
- [ ] Start with a minimal test (e.g., `id` command, `<script>alert(1)</script>`)
- [ ] Verify the vulnerability exists
- [ ] If blocked, identify the defense and find a bypass

### 4.2 Escalate to Flag
- [ ] Read flag file
- [ ] Extract from database
- [ ] Steal from admin (XSS + webhook)
- [ ] Compute the solution (crypto)

## Phase 5: If Stuck

### 5.1 Common Blind Spots
- [ ] MIME/content-type confusion
- [ ] Parser differentials (different parsers see different things)
- [ ] Unicode/normalization issues
- [ ] Prototype pollution (JavaScript)
- [ ] Deserialization gadgets
- [ ] Request smuggling
- [ ] Cache poisoning

### 5.2 Red Flags That You're Overcomplicating
- [ ] You've been on the same theory for >15 minutes
- [ ] Your attack requires multiple unlikely conditions
- [ ] You're trying to break cryptography
- [ ] The solution doesn't match the challenge hint

**Action**: Step back. Re-read the challenge. List 3 completely different approaches.

### 5.3 When to Pivot
If you're going in circles, systematically enumerate:
1. What do I control? (inputs)
2. What do I need? (flag location)
3. What's between them? (defenses)
4. List EVERY possible path from input to flag, no matter how unlikely
5. Test the simplest paths first
