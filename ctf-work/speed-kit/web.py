#!/usr/bin/env python3
"""Speed-kit: web.  Pre-stage this.  Edit URL and run."""
import sys, requests, re
from urllib.parse import urljoin

URL = "http://CHANGEME/"

def main():
    s = requests.Session()
    r = s.get(URL, timeout=5)
    print(f"[{r.status_code}] {len(r.text)} bytes")
    print(r.text[:500])
    print("...")
    # search for picoCTF flag
    m = re.search(r"picoCTF\{[^}]+\}", r.text)
    if m:
        print(f"\n[FLAG] {m.group(0)}")

if __name__ == "__main__":
    main()
