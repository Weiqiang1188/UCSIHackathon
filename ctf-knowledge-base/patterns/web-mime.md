# Pattern: MIME Parsing Differential

## Overview

When an application uses TWO different parsers to process the same input,
they may interpret the structure differently. This is especially common with
MIME/email processing where the email structure can be ambiguous.

## Attack Surface

Any application where:
1. Multiple parsers process the same raw input
2. The parsers have different implementations (different languages, libraries, WASM)
3. One parser's output determines code paths for another parser's output

## Common Scenarios

### Scenario 1: Email + Web Rendering
- **Parser A** (backend): Python `email` library generates MIME structure
- **Parser B** (frontend): JavaScript/WASM email parser extracts content for display
- **Target**: Make Parser B see HTML where Parser A only intended plain text

### Scenario 2: Signature Verification
- **Parser A**: Determines if content is "signed" and should be verified
- **Parser B**: Verifies the signature and extracts verified content
- **Target**: Make Parser A enter the "signed" code path while Parser B verifies
  different content than what gets rendered

### Scenario 3: Content-Type Confusion
- **Parser A**: Reads Content-Type from headers
- **Parser B**: Sniffs content from body (MIME sniffing)
- **Target**: Make parsers disagree on whether content is HTML

## Attack Techniques

### 1. Embedded MIME Structures
```
Content-Type: text/plain

[plain text body that contains...]

Content-Type: multipart/signed; boundary="x"
--x
Content-Type: text/html
<script>alert(1)</script>
--x
Content-Type: application/pkcs7-signature
<valid signature>
--x--
```
- A strict parser sees: text/plain with text content
- A lenient parser sees: multipart/signed with HTML inside

### 2. Boundary Confusion
Use boundary strings that confuse one parser but not the other:
- Boundaries with special characters: `"`, `\`, `\r`, `\n`
- Unicode lookalike characters that appear as boundary separators
- Overlapping boundaries: `--boundary` vs `--boundary--`

### 3. Header Injection in MIME Parts
```
Subject: test
Content-Type: text/html; boundary="fake"

--fake
<script>alert(1)</script>
--fake--
```
If subject allows CRLF injection, additional MIME headers can be injected.

### 4. Nested Signed Content
Embed a valid signed email inside an unsigned email:
```
Content-Type: multipart/mixed; boundary="outer"
--outer
Content-Type: text/html
[XSS PAYLOAD]
--outer
Content-Type: multipart/signed; boundary="inner"
[VALID SIGNED EMAIL]
--inner--
--outer--
```

## Detection

- [ ] Are there multiple places where the same data is parsed?
- [ ] Is a WASM binary used for parsing (different from native parsing)?
- [ ] Does one parser control a security decision (signature check)?
- [ ] Can the input be structured ambiguously?

## Exploitation Template

```python
def craft_ambiguous_email(xss_payload, valid_signed_data):
    """Create an email that different parsers interpret differently."""
    return f"""Content-Type: multipart/mixed; boundary="outer"

--outer
Content-Type: text/html

{xss_payload}

--outer
Content-Type: multipart/signed; boundary="inner"; protocol="application/pkcs7-signature"

{valid_signed_data}

--inner--

--outer--"""
```

## Related CVEs
- CVE-2023-XXXX: MIME parsing confusion in email clients
- CVE-2022-XXXX: Content-Type sniffing bypass

## Key Lesson
> **When two parsers process one input, find the edge case where they disagree.**
