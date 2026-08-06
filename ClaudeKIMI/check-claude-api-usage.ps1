# Check if Claude Code is actually using the Moonshot API override

Write-Host "=== Checking Claude Code API Override ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Important Note:" -ForegroundColor Yellow
Write-Host "The Claude Code UI might show 'Sonnet 4.5' as a default label," -ForegroundColor White
Write-Host "but the actual API calls should go to Moonshot AI if environment" -ForegroundColor White
Write-Host "variables are set correctly." -ForegroundColor White
Write-Host ""

# Check environment variables
Write-Host "1. Environment Variables (must be set BEFORE starting Claude Code):" -ForegroundColor Yellow
Write-Host "   ANTHROPIC_BASE_URL: $env:ANTHROPIC_BASE_URL" -ForegroundColor Cyan
if ($env:ANTHROPIC_BASE_URL -eq "https://api.moonshot.ai/anthropic") {
    Write-Host "   [OK] Correctly set to Moonshot AI" -ForegroundColor Green
} else {
    Write-Host "   [WRONG] Not set to Moonshot AI" -ForegroundColor Red
}

Write-Host "   ANTHROPIC_AUTH_TOKEN: $(if ($env:ANTHROPIC_AUTH_TOKEN) { '[SET]' } else { '[NOT SET]' })" -ForegroundColor Cyan
Write-Host ""

# Check if variables are in profile
Write-Host "2. PowerShell Profile (permanent settings):" -ForegroundColor Yellow
if (Test-Path $PROFILE) {
    $profile = Get-Content $PROFILE -Raw
    if ($profile -like "*moonshot.ai*") {
        Write-Host "   [OK] Moonshot URL in profile" -ForegroundColor Green
    } else {
        Write-Host "   [WARNING] Not in profile - only current session" -ForegroundColor Yellow
    }
} else {
    Write-Host "   [WARNING] No profile found" -ForegroundColor Yellow
}
Write-Host ""

# Instructions
Write-Host "=== How to Ensure Override Works ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Make sure environment variables are set BEFORE running 'claude':" -ForegroundColor Yellow
Write-Host "   $env:ANTHROPIC_BASE_URL = 'https://api.moonshot.ai/anthropic'" -ForegroundColor White
Write-Host "   $env:ANTHROPIC_AUTH_TOKEN = 'sk-...'" -ForegroundColor White
Write-Host ""
Write-Host "2. The UI might show 'Sonnet 4.5' but actual API calls go to Moonshot" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. To verify it's working, ask Claude Code:" -ForegroundColor Yellow
Write-Host "   'What API endpoint are you using?'" -ForegroundColor White
Write-Host "   or" -ForegroundColor White
Write-Host "   'Are you connected to Moonshot AI?'" -ForegroundColor White
Write-Host ""
Write-Host "4. If the UI doesn't update, the override might still work in the background" -ForegroundColor Yellow
Write-Host "   The important thing is that API calls go to Moonshot, not Anthropic" -ForegroundColor White

