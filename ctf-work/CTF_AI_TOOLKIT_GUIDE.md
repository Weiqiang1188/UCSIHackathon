# 🛡️ CTF AI Solver Toolkit & Resource Guide

This guide integrates modern autonomous agent designs (OODA loops, context pruning, structural markup blocks) directly into our repository workflow.

---

## 1. System Prompts & Code Auditing Patterns

### 🔍 Web Source Review Prompt
```text
You are an expert white-hat source code auditor. Review the provided code snippet for vulnerabilities. Focus on:
1. Dangerous sinks (eval, exec, system, popen, os.system).
2. Injection flaws (SQLi, Command Injection, SSRF, SSTI).
3. Logic flaws (Type juggling, loose comparisons, broken access control).
Output your findings in a structured list: Vulnerability Type, Vulnerable Line, and a Proof of Concept (PoC) template.
```

### 🧠 Pwn / Decompiler Explainer Prompt
```text
The following text is pseudo-code from a decompiler. 
1. Re-write this function in clean, readable C.
2. Rename generic variables (e.g., local_1c, pvVar1) to meaningful names based on context.
3. Identify if there is a memory corruption vulnerability (Buffer Overflow, Use-After-Free, Format String).
4. Explain the exact mathematical constraints required to reach the vulnerable code path.
```

---

## 2. Autonomous Loop & Context Optimization

### ⚡ Operational Rules for Hard Challenges
1. **OODA Loop (Observe-Orient-Decide-Act)**: Observe outputs -> Orient state in `notes.txt` -> Decide strategy -> Act via structured markup blocks.
2. **Context Pruning**: Never dump entire >1000 line source files or 50MB log files into LLM context. Slice large outputs (`head -50` and `tail -50`).
3. **Precision Patching**: Avoid rewriting entire script files for minor edits. Use line range search-and-replace (`PATCH_FILE` pattern).

---

## 3. Structural Markup Block Protocol

| Block | Syntax | Purpose |
| :--- | :--- | :--- |
| **Run Command** | `[COMMAND timeout=30] python3 solve.py [/COMMAND]` | Execute terminal commands with explicit execution bounds |
| **Write File** | `[WRITE_FILE:solve.py] ... [/WRITE_FILE]` | Create clean solver script |
| **Read File** | `[READ_FILE:vuln.c] [/READ_FILE]` | Inspect file with automatic truncation |
| **Append Notes** | `[APPEND_FILE:notes.txt] ... [/APPEND_FILE]` | Incrementally store state without losing history |
| **Patch File** | `[PATCH_FILE:solve.py]`<br>`<<<<<<< SEARCH`<br>`old_code`<br>`=======`<br>`new_code`<br>`>>>>>>> REPLACE`<br>`[/PATCH_FILE]` | Hot-patch specific script sections |
