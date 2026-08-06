# Verify if Claude Code is using Kimi K2

Write-Host "=== Verifying Kimi K2 Bypass ===" -ForegroundColor Cyan
Write-Host ""

# Check 1: API Base URL
Write-Host "1. API Base URL:" -ForegroundColor Yellow
if ($env:ANTHROPIC_BASE_URL) {
    if ($env:ANTHROPIC_BASE_URL -eq "https://api.moonshot.ai/anthropic") {
        Write-Host "   [OK] Using Moonshot AI (Kimi K2)" -ForegroundColor Green
        Write-Host "   URL: $env:ANTHROPIC_BASE_URL" -ForegroundColor Cyan
    } else {
        Write-Host "   [WRONG] Still using Anthropic" -ForegroundColor Red
        Write-Host "   Current: $env:ANTHROPIC_BASE_URL" -ForegroundColor Red
    }
} else {
    Write-Host "   [MISSING] Not configured" -ForegroundColor Red
}

# Check 2: API Token
Write-Host ""
Write-Host "2. API Token:" -ForegroundColor Yellow
if ($env:ANTHROPIC_AUTH_TOKEN) {
    Write-Host "   [OK] Token is set" -ForegroundColor Green
} else {
    Write-Host "   [MISSING] Not configured" -ForegroundColor Red
}

# Check 3: Profile (permanent)
Write-Host ""
Write-Host "3. PowerShell Profile (permanent):" -ForegroundColor Yellow
if (Test-Path $PROFILE) {
    $profileContent = Get-Content $PROFILE -Raw
    if ($profileContent -like "*moonshot.ai*") {
        Write-Host "   [OK] Moonshot URL in profile" -ForegroundColor Green
    } else {
        Write-Host "   [WARNING] Only set for current session" -ForegroundColor Yellow
    }
} else {
    Write-Host "   [WARNING] No profile found" -ForegroundColor Yellow
}

# Check 4: Region bypass
Write-Host ""
Write-Host "4. Region Bypass:" -ForegroundColor Yellow
$configPath = "$env:USERPROFILE\.claude.json"
if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
    if ($config.hasCompletedOnboarding -eq $true) {
        Write-Host "   [OK] Region bypass active" -ForegroundColor Green
    } else {
        Write-Host "   [MISSING] Not configured" -ForegroundColor Red
    }
} else {
    Write-Host "   [MISSING] Config file not found" -ForegroundColor Red
}

# Summary
Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host ""

if ($env:ANTHROPIC_BASE_URL -eq "https://api.moonshot.ai/anthropic") {
    Write-Host "[YES] You ARE using Kimi K2!" -ForegroundColor Green
    Write-Host ""
    Write-Host "When you run 'claude', it will:" -ForegroundColor Yellow
    Write-Host "  - Use Claude Code interface" -ForegroundColor White
    Write-Host "  - Connect to Moonshot AI (not Anthropic)" -ForegroundColor White
    Write-Host "  - Use Kimi K2 model" -ForegroundColor White
    Write-Host ""
    Write-Host "You've successfully bypassed Claude!" -ForegroundColor Green
} else {
    Write-Host "[NO] Still using default Claude" -ForegroundColor Red
    Write-Host ""
    Write-Host "You need to set:" -ForegroundColor Yellow
    Write-Host "  ANTHROPIC_BASE_URL = https://api.moonshot.ai/anthropic" -ForegroundColor White
}

