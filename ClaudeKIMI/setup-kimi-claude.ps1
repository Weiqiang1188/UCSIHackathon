# Kimi K2 + Claude Code Integration Setup Script
# Based on: https://github.com/ShenSeanChen/yt-kimi-k2-claude.git
# This script sets up Claude Code to use Moonshot AI's Kimi K2 model

Write-Host "=== Kimi K2 + Claude Code Integration Setup ===" -ForegroundColor Cyan
Write-Host "This setup redirects Claude Code to use Moonshot AI's Kimi K2 model`n" -ForegroundColor Yellow

# Step 1: Install Claude Code globally
Write-Host "[1/5] Installing Claude Code globally..." -ForegroundColor Yellow
npm install -g @anthropic-ai/claude-code
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✓ Claude Code installed" -ForegroundColor Green
} else {
    Write-Host "   ✗ Installation failed" -ForegroundColor Red
    exit 1
}

# Step 2: Fix PATH configuration
Write-Host "`n[2/5] Configuring PATH..." -ForegroundColor Yellow
$npmPath = "C:\Users\weiqi\AppData\Roaming\npm"
$env:PATH = "$npmPath;$env:PATH"

# Add to PowerShell profile permanently
if (!(Test-Path $PROFILE)) { 
    New-Item -Path $PROFILE -Type File -Force | Out-Null
}
$profileLine = '$env:PATH = "C:\Users\weiqi\AppData\Roaming\npm;$env:PATH"'
$profileContent = Get-Content $PROFILE -ErrorAction SilentlyContinue
if ($profileContent -notcontains $profileLine) {
    Add-Content -Path $PROFILE -Value $profileLine
    Write-Host "   ✓ PATH added to PowerShell profile" -ForegroundColor Green
} else {
    Write-Host "   ✓ PATH already in profile" -ForegroundColor Green
}

# Step 3: Configure API access
Write-Host "`n[3/5] Configuring API access (Moonshot AI)..." -ForegroundColor Yellow
$env:ANTHROPIC_AUTH_TOKEN = "sk-RNVgHcIvFy4UmRet4j7gSGs5lTB9XmwBqEscC9ydHJ00tGsu"
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"
Write-Host "   ✓ API endpoint: $env:ANTHROPIC_BASE_URL" -ForegroundColor Green
Write-Host "   ✓ API token configured" -ForegroundColor Green

# Step 4: Bypass region restrictions
Write-Host "`n[4/5] Bypassing region restrictions..." -ForegroundColor Yellow
$claudeConfig = Join-Path $env:USERPROFILE ".claude.json"
$configContent = @{
    hasCompletedOnboarding = $true
} | ConvertTo-Json
Set-Content -Path $claudeConfig -Value $configContent
Write-Host "   ✓ Config file created: $claudeConfig" -ForegroundColor Green

# Step 5: Verify installation
Write-Host "`n[5/5] Verifying installation..." -ForegroundColor Yellow
$version = claude --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✓ Claude CLI version: $version" -ForegroundColor Green
} else {
    Write-Host "   ✗ Claude CLI not accessible" -ForegroundColor Red
}

Write-Host "`n=== Setup Complete! ===" -ForegroundColor Green
Write-Host "`nArchitecture:" -ForegroundColor Cyan
Write-Host "  Your Terminal → Claude Code CLI → Moonshot AI → Kimi K2 (1T params)" -ForegroundColor White
Write-Host "`nTo start using Claude Code with Kimi K2, run:" -ForegroundColor Yellow
Write-Host "  claude" -ForegroundColor White
Write-Host "`nNote: Environment variables are set for this session." -ForegroundColor Yellow
Write-Host "To make them permanent, add to your PowerShell profile." -ForegroundColor Yellow

