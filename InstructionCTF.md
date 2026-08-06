Help me write a Python exploit script to solve a Web Exploitation CTF challenge called "byp4ss3d".

Challenge Info:
- Target URL: http://amiable-citadel.picoctf.net:52639/
- Objective: Bypass the file upload filter on the registration portal to upload a payload and get Remote Code Execution (RCE) to read the flag.

Upload Rules & Server Setup (from looking at the source code/network requests):
- Web Server: [e.g., Apache/2.4.x]
- File restrictions in place: [e.g., Client-side extensions check only / Checks mime-type / Checks image headers]
- The destination folder where files are uploaded: [e.g., /uploads/ or /images/]
- Allowed extensions: [e.g., .png, .jpg, .jpeg]

Please:
1. Explain the conceptual bypass method for this setup (e.g., using an .htaccess configuration file bypass if it is an Apache server, or extension double suffixes like .php.png, null byte injection, or MIME-type spoofing).
2. Provide a Python script using the 'requests' library to:
   - Handle any initial session or CSRF token retrieval if needed.
   - Upload the bypass files (e.g., uploading the configuration and payload files).
   - Send a test command (like 'id' or 'ls') to verify remote code execution.
