# 🚀 Kimi K2 + Claude Code Integration Setup

Based on: [yt-kimi-k2-claude repository](https://github.com/ShenSeanChen/yt-kimi-k2-claude.git)

## What This Does

This setup allows you to use **Kimi K2** (Moonshot AI's 1T parameter model) through Claude Code by redirecting API calls to the Moonshot AI endpoint.

### Architecture Flow
```
Your Terminal → Claude Code CLI → Moonshot AI API → Kimi K2 (1T params)
```

### Performance Advantages

According to the repository, Kimi K2 outperforms Claude Sonnet 4:
- **LiveCodeBench v6**: 53.7% vs 47.4% (+6.3%)
- **AIME 2024**: 69.6% vs 43.4% (+26.2%)
- **Tool Use**: 90.2% vs ~85% (+5.2%)
- **Agentic Benchmarks**: 70.6% vs ~65% (+5.6%)

## Setup Steps

### Quick Setup (PowerShell)

Run the setup script:
```powershell
.\setup-kimi-claude.ps1
```

### Manual Setup

1. **Install Claude Code globally**
   ```powershell
   npm install -g @anthropic-ai/claude-code
   ```

2. **Fix PATH configuration**
   ```powershell
   # For current session
   $env:PATH = "C:\Users\weiqi\AppData\Roaming\npm;$env:PATH"
   
   # Permanent (add to PowerShell profile)
   if (!(Test-Path $PROFILE)) { New-Item -Path $PROFILE -Type File -Force }
   Add-Content -Path $PROFILE -Value '$env:PATH = "C:\Users\weiqi\AppData\Roaming\npm;$env:PATH"'
   . $PROFILE
   ```

3. **Configure API access**
   ```powershell
   $env:ANTHROPIC_AUTH_TOKEN = "sk-RNVgHcIvFy4UmRet4j7gSGs5lTB9XmwBqEscC9ydHJ00tGsu"
   $env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"
   ```

4. **Bypass region restrictions**
   ```powershell
   node -e "const fs=require('fs'),os=require('os'),path=require('path'); const file=path.join(os.homedir(),'.claude.json'); fs.writeFileSync(file,JSON.stringify({hasCompletedOnboarding:true},null,2));"
   ```

5. **Launch Claude Code**
   ```powershell
   claude
   ```

## Verification

Check that everything is set up correctly:

```powershell
# Check Claude CLI version
claude --version

# Verify PATH
$env:PATH -like "*AppData\Roaming\npm*"

# Verify API variables
$env:ANTHROPIC_BASE_URL
$env:ANTHROPIC_AUTH_TOKEN

# Check config file
Test-Path "$env:USERPROFILE\.claude.json"
```

## Making Environment Variables Permanent

To make the API environment variables persist across sessions, add them to your PowerShell profile:

```powershell
# Edit your profile
notepad $PROFILE

# Add these lines:
$env:ANTHROPIC_AUTH_TOKEN = "sk-RNVgHcIvFy4UmRet4j7gSGs5lTB9XmwBqEscC9ydHJ00tGsu"
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"
```

## Usage

Once set up, simply run:
```powershell
claude
```

This will start Claude Code, which will now use Kimi K2 through the Moonshot AI endpoint instead of the default Anthropic API.

## Troubleshooting

### Claude CLI not found
- Make sure PATH is configured correctly
- Restart your terminal after adding to profile
- Verify: `npm list -g @anthropic-ai/claude-code`

### API connection issues
- Verify your Moonshot AI API key is correct
- Check that `ANTHROPIC_BASE_URL` is set to `https://api.moonshot.ai/anthropic`
- Ensure environment variables are set in your current session

### Region restrictions
- The `.claude.json` file should exist in your home directory
- Verify: `Get-Content "$env:USERPROFILE\.claude.json"`

## Files

- `setup-kimi-claude.ps1` - Automated setup script
- `Kimiclaude` - Manual setup commands reference
- `KIMI-CLAUDE-SETUP.md` - This documentation

## References

- [GitHub Repository](https://github.com/ShenSeanChen/yt-kimi-k2-claude.git)
- [Moonshot AI Documentation](https://platform.moonshot.cn/)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)

