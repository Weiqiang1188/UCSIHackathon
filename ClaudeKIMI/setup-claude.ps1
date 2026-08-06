# Claude CLI Setup Script for Windows
# This script configures Claude CLI with your Moonshot AI endpoint

Write-Host "Setting up Claude CLI..." -ForegroundColor Green

# Add Claude CLI to PATH for current session
$claudePath = "$env:USERPROFILE\.local\bin"
if ($env:PATH -notlike "*$claudePath*") {
    $env:PATH += ";$claudePath"
    Write-Host "Added Claude CLI to PATH for this session" -ForegroundColor Yellow
}

# Set environment variables for Moonshot AI endpoint
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"
$env:ANTHROPIC_AUTH_TOKEN = "sk-RNVgHcIvFy4UmRet4j7gSGs5lTB9XmwBqEscC9ydHJ00tGsu"

Write-Host "Environment variables set:" -ForegroundColor Green
Write-Host "  ANTHROPIC_BASE_URL: $env:ANTHROPIC_BASE_URL"
Write-Host "  ANTHROPIC_AUTH_TOKEN: [HIDDEN]"

# Verify Claude CLI is accessible
Write-Host "`nVerifying Claude CLI installation..." -ForegroundColor Green
try {
    $version = & claude --version 2>&1
    Write-Host "Claude CLI version: $version" -ForegroundColor Green
} catch {
    Write-Host "Warning: Claude CLI not found in PATH" -ForegroundColor Yellow
    Write-Host "You may need to restart your terminal or add $claudePath to your system PATH permanently" -ForegroundColor Yellow
}

Write-Host "`nSetup complete! You can now run 'claude' to start using the CLI." -ForegroundColor Green
Write-Host "Note: Standard Claude CLI uses web authentication. For custom endpoints," -ForegroundColor Yellow
Write-Host "you may need to use the Anthropic Python SDK or other tools." -ForegroundColor Yellow

