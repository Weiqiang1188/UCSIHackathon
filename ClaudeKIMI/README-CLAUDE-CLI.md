# Claude CLI Setup Guide

## Installation Status
✅ Claude CLI is installed at: `C:\Users\weiqi\.local\bin\claude.exe` (Version 2.0.37)

## Quick Start

### Option 1: Use the Setup Script (Recommended)
Run the PowerShell setup script:
```powershell
.\setup-claude.ps1
```

Or use the quick script:
```powershell
.\O.ps1
```

### Option 2: Manual Setup
1. Add Claude CLI to your PATH (for current session):
```powershell
$env:PATH += ";$env:USERPROFILE\.local\bin"
```

2. Set your environment variables:
```powershell
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"
$env:ANTHROPIC_AUTH_TOKEN = "sk-RNVgHcIvFy4UmRet4j7gSGs5lTB9XmwBqEscC9ydHJ00tGsu"
```

3. Run Claude CLI:
```powershell
claude
```

## Permanent PATH Setup (Optional)

To make Claude CLI available in all terminals, add it to your system PATH:

1. Open System Properties → Environment Variables
2. Edit the "Path" variable under User variables
3. Add: `C:\Users\weiqi\.local\bin`
4. Restart your terminal

Or use PowerShell (run as Administrator):
```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$env:USERPROFILE\.local\bin", "User")
```

## Important Notes

⚠️ **Custom Endpoint Limitation**: The standard Claude CLI is designed to work with Anthropic's official API and uses web-based authentication. It may not directly support custom endpoints like Moonshot AI through environment variables.

### If Custom Endpoints Don't Work

If you need to use the Moonshot AI endpoint, consider:

1. **Use Anthropic Python SDK** with custom endpoints:
```python
from anthropic import Anthropic

client = Anthropic(
    base_url="https://api.moonshot.ai/anthropic",
    api_key="sk-RNVgHcIvFy4UmRet4j7gSGs5lTB9XmwBqEscC9ydHJ00tGsu"
)
```

2. **Try the standard Claude CLI authentication**:
```powershell
claude setup-token
```
This will prompt you to authenticate via web browser.

## Available Commands

- `claude` - Start interactive session
- `claude "your prompt"` - Run a one-time command
- `claude --help` - Show all available options
- `claude --version` - Check version
- `claude setup-token` - Set up authentication token

## Troubleshooting

If `claude` command is not found:
- Make sure you've added `C:\Users\weiqi\.local\bin` to your PATH
- Restart your terminal after adding to PATH
- Run the setup script: `.\setup-claude.ps1`

