# 🚀 Kimi K2 + Claude Code Complete Setup Guide

**PowerShell Version for Windows**

Based on: [yt-kimi-k2-claude repository](https://github.com/ShenSeanChen/yt-kimi-k2-claude.git)

---

## 📋 Overview

This guide explains how to set up **Kimi K2** (Moonshot AI's 1T parameter model) with **Claude Code** (Anthropic's CLI tool). This integration gives you access to Kimi K2's superior coding capabilities through Claude Code's professional interface.

### 🔧 Technical Architecture

```
Your Terminal
      ↓
Claude Code CLI (Anthropic's interface)
      ↓
ANTHROPIC_BASE_URL redirect
      ↓
Moonshot AI API (api.moonshot.ai)
      ↓
Kimi K2 Model (1T parameters, MoE architecture)
```

### 🎯 Why This Setup?

- **Best of Both Worlds**: Claude Code's proven UX + Kimi K2's cutting-edge AI capabilities
- **Superior Performance**: Kimi K2 outperforms Claude Sonnet 4 on coding benchmarks
- **Professional Interface**: Full-featured CLI with rich development tools

---

## 🛠️ Step-by-Step Setup

### **Step 1: Install Claude Code**

```powershell
npm install -g @anthropic-ai/claude-code
```

**Why this step is needed:**
- Claude Code is Anthropic's official CLI tool for AI-assisted coding
- The `-g` flag installs it globally, making the `claude` command available system-wide
- This gives us a professional, feature-rich interface for interacting with AI models

---

### **Step 2: Fix PATH Configuration**

```powershell
# Check where npm installed Claude Code
npm list -g @anthropic-ai/claude-code

# Add npm global bin to PATH (temporary fix for current session)
$env:PATH = "C:\Users\weiqi\AppData\Roaming\npm;$env:PATH"

# Permanent fix - add to PowerShell profile
if (!(Test-Path $PROFILE)) { New-Item -Path $PROFILE -Type File -Force }
$profileLine = '$env:PATH = "C:\Users\weiqi\AppData\Roaming\npm;$env:PATH"'
if ((Get-Content $PROFILE -ErrorAction SilentlyContinue) -notcontains $profileLine) {
    Add-Content -Path $PROFILE -Value $profileLine
}
. $PROFILE

# Verify it works
claude --version
```

**Why this step is needed:**
- npm installed Claude Code to a custom directory (`C:\Users\weiqi\AppData\Roaming\npm`)
- This directory wasn't in your system's PATH environment variable
- Without PATH configuration, the shell can't find the `claude` command
- The permanent fix ensures the command works in all future terminal sessions

**Note:** Replace `C:\Users\weiqi\AppData\Roaming\npm` with your actual npm global bin path. Find it with:
```powershell
npm config get prefix
```

---

### **Step 3: Bypass Region Restrictions**

```powershell
# Create/update the .claude.json config file
$homeDir = $env:USERPROFILE
$configPath = Join-Path $homeDir ".claude.json"

$config = @{}
if (Test-Path $configPath) {
    $existingContent = Get-Content $configPath -Raw | ConvertFrom-Json
    $existingContent.PSObject.Properties | ForEach-Object {
        $config[$_.Name] = $_.Value
    }
}

$config.hasCompletedOnboarding = $true
$jsonContent = $config | ConvertTo-Json -Depth 10
Set-Content -Path $configPath -Value $jsonContent
```

**Why this step is needed:**
- Claude Code normally performs region/country verification
- This verification can block access in certain regions
- Setting `hasCompletedOnboarding: true` bypasses this check
- The config file is created at `C:\Users\weiqi\.claude.json`

---

### **Step 4: Configure Kimi K2 API Access**

```powershell
# Set up environment variables for Kimi K2 access (current session)
$env:ANTHROPIC_AUTH_TOKEN = "sk-your-moonshot-api-key"
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"

# Make it permanent - add to PowerShell profile
if (!(Test-Path $PROFILE)) { New-Item -Path $PROFILE -Type File -Force }
$tokenLine = '$env:ANTHROPIC_AUTH_TOKEN = "sk-your-moonshot-api-key"'
$urlLine = '$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"'

$profileContent = Get-Content $PROFILE -ErrorAction SilentlyContinue
if ($profileContent -notcontains $tokenLine) {
    Add-Content -Path $PROFILE -Value $tokenLine
}
if ($profileContent -notcontains $urlLine) {
    Add-Content -Path $PROFILE -Value $urlLine
}
. $PROFILE
```

**Why this step is needed:**
- Claude Code was designed for Anthropic's API, but we want to use Kimi K2
- `ANTHROPIC_AUTH_TOKEN`: Your Moonshot AI API key (starts with `sk-`)
- `ANTHROPIC_BASE_URL`: Redirects API calls to Moonshot's servers instead of Anthropic's
- This allows Claude Code's interface to work with Kimi K2's backend

**Important:** Replace `sk-your-moonshot-api-key` with your actual Moonshot AI API key!

---

### **Step 5: Test the Setup**

```powershell
# Navigate to your project directory
cd C:\Users\weiqi\OneDrive\Desktop\ClaudeKIMI

# Launch Claude Code
claude
```

**Why this step is needed:**
- Verifies that all configuration steps worked correctly
- You should see Claude Code's interface without region verification prompts
- The tool will now use Kimi K2 for AI assistance instead of Claude models

---

## 🚀 Quick Setup (Automated)

Run the complete setup script:

```powershell
.\KIMI-K2-COMPLETE-SETUP.ps1
```

This script automates all 5 steps above with proper error handling and verification.

---

## ✅ Verification Checklist

After setup, verify everything works:

```powershell
# 1. Check Claude CLI version
claude --version
# Should output: 2.0.37 (Claude Code) or similar

# 2. Verify PATH
$env:PATH -like "*AppData\Roaming\npm*"
# Should output: True

# 3. Check API variables
$env:ANTHROPIC_BASE_URL
# Should output: https://api.moonshot.ai/anthropic

$env:ANTHROPIC_AUTH_TOKEN
# Should output: sk-... (your API key)

# 4. Check config file
Test-Path "$env:USERPROFILE\.claude.json"
# Should output: True

Get-Content "$env:USERPROFILE\.claude.json"
# Should show: "hasCompletedOnboarding": true
```

---

## 📊 Performance Comparison

According to benchmarks, Kimi K2 outperforms Claude Sonnet 4:

| Benchmark           | Kimi K2   | Claude Sonnet 4 | Advantage  |
| ------------------- | --------- | --------------- | ---------- |
| LiveCodeBench v6    | **53.7%** | 47.4%           | **+6.3%**  |
| AIME 2024           | **69.6%** | 43.4%           | **+26.2%** |
| Tool Use (Berkeley) | **90.2%** | ~85%            | **+5.2%**  |
| Agentic Benchmarks  | **70.6%** | ~65%            | **+5.6%**  |

---

## 🔧 Troubleshooting

### Claude CLI not found
- **Solution**: Make sure PATH is configured correctly
- **Check**: `npm list -g @anthropic-ai/claude-code`
- **Fix**: Restart terminal or run `. $PROFILE`

### API connection issues
- **Solution**: Verify your Moonshot AI API key is correct
- **Check**: `$env:ANTHROPIC_BASE_URL` should be `https://api.moonshot.ai/anthropic`
- **Fix**: Re-run Step 4 to set environment variables

### Region restrictions still appear
- **Solution**: Verify `.claude.json` exists and has correct content
- **Check**: `Get-Content "$env:USERPROFILE\.claude.json"`
- **Fix**: Re-run Step 3 to create/update the config file

### Environment variables not persisting
- **Solution**: Add them to your PowerShell profile
- **Check**: `Get-Content $PROFILE`
- **Fix**: Re-run Step 4 to add to profile

---

## 📁 Files in This Setup

- `KIMI-K2-COMPLETE-SETUP.ps1` - Automated setup script
- `KIMI-K2-SETUP-GUIDE.md` - This documentation
- `Kimiclaude` - Quick reference commands
- `fix_claude_config.ps1` - Config file fix script
- `setup-kimi-claude.ps1` - Alternative setup script

---

## 🎯 Key Insights

The key insight is that we're using **Claude Code as a high-quality interface** while **redirecting the backend to Kimi K2's more powerful model**. This gives us:

- ✅ **Proven UX**: Claude Code's professional development interface
- ✅ **Cutting-edge AI**: Kimi K2's superior coding capabilities
- ✅ **Best of Both Worlds**: The perfect combination!

---

## 📚 References

- [GitHub Repository](https://github.com/ShenSeanChen/yt-kimi-k2-claude.git)
- [Moonshot AI Documentation](https://platform.moonshot.cn/)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)

---

**🎉 Ready to experience the future of AI-assisted development with Kimi K2 + Claude Code!**

