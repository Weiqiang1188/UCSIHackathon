#!/usr/bin/env bash
# Speed-kit: recon.  Run this in the binary's folder.
# Usage: ./recon.sh <binary>
BIN="${1:-./binary}"
echo "=== file ==="
file "$BIN"
echo
echo "=== checksec ==="
python -c "from pwn import *; e=ELF('$BIN'); e.checksec" 2>/dev/null || true
echo
echo "=== strings (flag-related) ==="
strings "$BIN" | grep -iE "flag|win|shell|password|secret|admin" | head -20
echo
echo "=== strings (commands) ==="
strings "$BIN" | grep -E "^[a-z_]{3,15}$" | sort -u | head -30
echo
echo "=== functions (objdump) ==="
objdump -d "$BIN" 2>/dev/null | grep -E "^[0-9a-f]+ <[^>]+>:" | head -20
echo
echo "=== size ==="
ls -la "$BIN"
