# 🎯 Final Guide: Using Kimi K2 in Claude Code

## ⚠️ Important Discovery

Based on testing, **Claude Code may not fully support API redirection** to third-party services like Moonshot AI. However, here are all the methods to try:

## 🔧 Method 1: Environment Variables with /v1 Endpoint

**Try this format (suggested by web search):**

```powershell
# Set variables
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/v1"
$env:ANTHROPIC_AUTH_TOKEN = "sk-KrTZIiWjc82pPFYNRIsg1kLMibCDnOtbU7ZA4etqYb9xV76k"

# Start Claude Code
claude
```

## 🔧 Method 2: Environment Variables with /anthropic Endpoint

**Original format from GitHub guide:**

```powershell
# Set variables
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"
$env:ANTHROPIC_AUTH_TOKEN = "sk-KrTZIiWjc82pPFYNRIsg1kLMibCDnOtbU7ZA4etqYb9xV76k"

# Start Claude Code
claude
```

## 🔧 Method 3: Using Settings File

```powershell
# Create settings file (already created: claude-settings.json)
claude --settings claude-settings.json
```

## 🧪 Testing Script

Run the test script to check if it's working:

```powershell
.\test-kimi-in-claude.ps1
```

This will:
1. Set environment variables
2. Test Claude Code
3. Check if it's using Moonshot AI
4. Try alternative formats if needed

## ✅ Verification

After starting Claude Code, ask it:

```
What API endpoint are you using? Are you connected to Moonshot AI?
```

**If it says Moonshot AI** → ✅ Success!

**If it says Anthropic** → ❌ Override not working

## 🔄 If Override Doesn't Work

If Claude Code still uses Anthropic's API, it means:

1. **Claude Code doesn't support API redirection** (most likely)
2. **The override method from GitHub doesn't work** with current Claude Code version
3. **You need to use direct API access** instead

## 🚀 Alternative: Direct Moonshot API

If the override doesn't work, use direct API access:

```powershell
# Python script (recommended)
python moonshot-api-direct.py

# Or PowerShell
. .\moonshot-api-powershell.ps1
Invoke-KimiChat -Prompt "Your question"
```

## 📝 Summary

**To try Kimi K2 in Claude Code:**

1. Close Claude Code if running
2. Set environment variables:
   ```powershell
   $env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/v1"
   $env:ANTHROPIC_AUTH_TOKEN = "sk-KrTZIiWjc82pPFYNRIsg1kLMibCDnOtbU7ZA4etqYb9xV76k"
   ```
3. Start Claude Code:
   ```powershell
   claude
   ```
4. Test:
   ```powershell
   claude --print "What API are you using?"
   ```

**If it doesn't work**, use the direct API scripts we created.





