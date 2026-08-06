# 🚀 Quick Start Guide

## 1. How to Find Your npm Path

### Method 1: Using npm config (Easiest)
```powershell
npm config get prefix
```
**Your path:** `C:\Users\weiqi\AppData\Roaming\npm`

### Method 2: Check where Claude is installed
```powershell
where.exe claude
```
This shows where the `claude` command is located.

### Method 3: Check npm global root
```powershell
npm root -g
```
The bin path is usually the parent directory of this.

---

## 2. How to Run the Setup

### Option A: Automated Setup (Recommended)
```powershell
# Just run this one command:
.\KIMI-K2-COMPLETE-SETUP.ps1
```

This script will:
- ✅ Find your npm path automatically
- ✅ Install everything
- ✅ Configure PATH permanently
- ✅ Set up API access
- ✅ Bypass region restrictions
- ✅ Verify everything works

### Option B: Manual Setup

If you prefer to do it step by step:

**Step 1: Install Claude Code**
```powershell
npm install -g @anthropic-ai/claude-code
```

**Step 2: Add to PATH (replace with YOUR path)**
```powershell
# Get your path first:
$yourPath = npm config get prefix

# Add to PATH for current session:
$env:PATH = "$yourPath;$env:PATH"

# Make it permanent:
if (!(Test-Path $PROFILE)) { New-Item -Path $PROFILE -Type File -Force }
Add-Content -Path $PROFILE -Value "`$env:PATH = `"$yourPath;`$env:PATH`""
. $PROFILE
```

**Step 3: Set API variables**
```powershell
$env:ANTHROPIC_AUTH_TOKEN = "sk-RNVgHcIvFy4UmRet4j7gSGs5lTB9XmwBqEscC9ydHJ00tGsu"
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"

# Make permanent:
Add-Content -Path $PROFILE -Value '`$env:ANTHROPIC_AUTH_TOKEN = "sk-RNVgHcIvFy4UmRet4j7gSGs5lTB9XmwBqEscC9ydHJ00tGsu"'
Add-Content -Path $PROFILE -Value '`$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"'
```

**Step 4: Bypass region restrictions**
```powershell
.\fix_claude_config.ps1
```

**Step 5: Test**
```powershell
claude --version
```

---

## 3. Your Specific Path

Based on your system:
- **Your npm global bin path:** `C:\Users\weiqi\AppData\Roaming\npm`
- **This is already configured in the setup scripts!**

---

## 4. Verify Everything Works

After setup, test:
```powershell
# Check Claude version
claude --version

# Check PATH
$env:PATH -like "*AppData\Roaming\npm*"

# Check API variables
$env:ANTHROPIC_BASE_URL
$env:ANTHROPIC_AUTH_TOKEN
```

---

## 5. Start Using It!

Once everything is set up:
```powershell
claude
```

This will start Claude Code, which will now use Kimi K2 through Moonshot AI!

---

## Need Help?

- Run `.\find-npm-path.ps1` to find your path
- Check `KIMI-K2-SETUP-GUIDE.md` for detailed documentation
- Run `.\KIMI-K2-COMPLETE-SETUP.ps1` for automated setup

