# Quick setup script - Run this to configure Claude CLI with Moonshot AI endpoint

# Add Claude CLI to PATH
$env:PATH += ";$env:USERPROFILE\.local\bin"

# Set environment variables for Moonshot AI endpoint
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"
$env:ANTHROPIC_AUTH_TOKEN = "sk-RNVgHcIvFy4UmRet4j7gSGs5lTB9XmwBqEscC9ydHJ00tGsu"

# Start Claude CLI
claude

