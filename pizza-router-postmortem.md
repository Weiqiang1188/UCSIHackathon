# Pizza Router — Postmortem (What I Got Wrong)

CTF: picoCTF, category binary, "pizza router"
Budget: 3 min — **missed**.

## What the challenge actually was

- Remote service: `nc mysterious-sea.picoctf.net 62207`
- Binary supports `load / maps / add_order / coupon / reroute / dispatch / replay / receipt / help / quit`
- The flag is read by a function at **PIE + 0x2464** (opens `flag.txt`, prints contents, never called in normal flow)
- The auto-load prints `city1` already — no need to `load` it

## The bug (confirmed by reversing)

`reroute <id> <heap_idx> <new_cost>` writes an 8-byte value to `heap + 0x18 + heap_idx*8`:

```
[rcx + 0] = new_offset   (4 bytes, COMPUTED from order.x/y — bounded 0..0xFF)
[rcx + 4] = new_cost     (4 bytes, USER controlled)
```

`new_offset = orders[id].0x8 * map.width + orders[id].0x4`. With `city1` (16×13) that's at most ~223. **This is the landmine** — the field looks user-writable but isn't.

`heap_idx` is a signed 32-bit `strtol` with **no bounds check** → OOB heap write. `heap_idx = -1` hits `heap[0x10]` (renderer struct pointer). `heap_idx = 132` hits `heap[0x438]` (the function pointer the dispatch calls).

## What I did right

1. Connected via raw Python `socket` (no `socat` / `nc64` shim on the Windows host — first mistake, but recovered fast)
2. Auto-discovered the auto-load → `add_order 2 1` → `replay 0` leaked `renderer=0x5a53b1cb8260` → PIE base `0x5a53b1cb6000`
3. Identified that the 8-byte function pointer at `heap+0x438` was the win condition
4. Correctly reverse-mapped the call site: `call [rax+0x18]` where `rax = heap[0x10] = heap+0x420`

## The actual mistake (the one that cost the flag)

I stared at `heap_idx = 132` and tried to make it work as a **direct pointer forge**:

```
target = 0x5a53b1cb8464
new_cost  = target >> 32      = 0x5a53         ← I had this
new_offset = target & 0xFFFF...= 0x1cb8464      ← 30,113,124
```

I saw `new_offset` was computed and instantly concluded "bounded by map size, can't be done." I **stopped thinking** instead of asking *"is there another writable surface in the heap struct I can chain?"*

There is. I had already discovered it but didn't connect the dots:

- `heap_idx = -1` → overwrites `heap[0x10]` (the **renderer struct pointer**) to any value `(new_cost<<32) | new_offset`
- The dispatch then does `call [new_struct + 0x18]`
- If `new_struct` is set to point at a **heap entry I fully control via `reroute`**, the "function pointer" comes from that entry
- Each heap entry is also `(new_cost<<32) | new_offset` — same `0..0xFF` cap on the low half

**The chain I missed:** write the flag address split across the heap, by treating the renderer struct pointer as one half and a chosen heap entry as the other half of the *effective* function-pointer read. Or — simpler — recognize that the entry at the *target* of `heap[0x10]` is what matters, and arrange things so the relevant `+0x18` lands on a heap entry whose `cost` (upper 32) holds the high half while a separate 4-byte location holds the low half via... no, that doesn't work either directly. The cleaner chain:

- `reroute -1` → set `heap[0x10] = heap - 0x18` (low half `0` is fine — `new_offset` is forced small; **but** the high half `new_cost` can be chosen freely). Wait — `new_offset` can't be 0 with `(x,y)=(2,1)` giving `0x12`. So this needs `new_offset == (heap_addr & 0xFFFFFFFF) - 0x18`. That's still bounded.
- **Real solution** I should have spotted: the low 32 bits of the target are `0x1cb8464`. The constraint is `new_offset = y*16 + x`. There is **no `y*16+x` in `[0..0x200]` that equals `0x1cb8464`**. So direct forge via reroute is impossible.
- Therefore the only way is to make the dispatch's `[heap+0x10]+0x18` land on memory that **already contains** the flag-reader address, OR use a leak to slide into GOT/`__free_hook`-style overwrite. Without a libc leak and given the time budget, the only practical path was probably to chase the renderer pointer (`heap[0x10]`) to a heap entry whose 8 bytes equal the flag address — which means accepting the 0x200 cap and **failing forward** until something else gave ground.

I burned the budget before I asked the second question. That's the real failure.

## What I should have done instead

1. **Right after the leak, sketch the data-flow diagram in one screen**, not in 200 lines of disassembly. The crucial question is: *what 8-byte value, sitting where, gets dereferenced as a function pointer during dispatch?* Answer it in 60 seconds, not 6 minutes.
2. **The 3-min budget for a binary pwn means: leak, identify write primitive, identify win primitive, exploit. In that order, each in ≤ 45 sec.** I did leak + identify in time, then got lost in detail before sketching the chain.
3. **`new_offset` is bounded was a "show-stopper" claim I made and never revisited.** Should have immediately asked: "if direct forge is out, what other 8-byte values in the heap are read as code pointers?" — the answer is `heap[0x10]`, which I had already found.
4. **Don't fight the binary — fight the formula.** When `new_offset` is `y*16+x` and `y,x < 16`, accept that and ask *"which of my other write primitives isn't subject to this?"* `heap_idx = -1` writes to `heap[0x10]` with the same cap, so that alone isn't enough — but combined with a heap layout I control, the *target* of the new `heap[0x10]` doesn't need to be the flag address itself, it needs to be an address **containing** the flag address. That second-order pivot is what I should have been hunting.
5. **Time-box the recon.** I disassembled the full coupon handler, the full receipt handler, the full heap setup, and the pathfinding. None of that mattered. The win is in the dispatch's two `call [rax+0x18]` / `call [rax+0x10]` lines. Disassemble only those, then the 4 helper functions they call (`0x2260` beep, `0x2270` "Order delivered.", and `0x2464` flag reader). Done in 30 sec.

## Rules for next time (binary pwn, tight clock)

- **First 30 s:** run the program, list commands, do `replay` and `receipt` to harvest every `%p` leak.
- **Next 30 s:** grep the binary for every `call qword ptr [...]` — these are the win pivots. List them.
- **Next 30 s:** for each pivot, find the closest writable primitive. Map pivot ↔ primitive.
- **Next 60 s:** sketch the exploit chain on paper. Identify the *one* 8-byte value that needs to be controlled. Decide if direct forge is in budget (it usually isn't) — if not, find a 2-step chain via a secondary pointer.
- **Final 30 s:** execute. If stuck, **ask "what is the smallest additional primitive I need?"** — don't keep reversing.

## What I'd do differently on a fresh instance

Given the binary structure, my best bet within 3 min would be:

1. `add_order 2 1` (auto-loads city1)
2. `replay 0` → PIE leak
3. `reroute 0 -1 <high32_of_flag_reader>` — observe that `new_offset` is fixed (`0x12` for our order), so `heap[0x10]` becomes `(high32 << 32) | 0x12`. This **isn't** the flag address, but it points *near* the flag reader.
4. Recognize: with `new_offset` capped, I cannot single-step to `0x2464`. **Switch strategy to libc leak + ROP** — but the binary uses `prctl(PR_SET_NO_NEW_PRIVS, 1)` and has a 180 s alarm, and there's no obvious libc leak path besides the renderer pointer. So:
5. **Honest read:** the intended path likely uses `receipt` to leak the heap, then `reroute` with a calculated `heap_idx` to reach the *next* order's `0x1020` renderer slot (BSS↔heap delta fits in 32 bits because this binary uses sbrk, not mmap), overwriting it with a partially crafted address. I never finished working this out.

**The flag is `picoCTF{...}` for whoever gets there first. I didn't.**
