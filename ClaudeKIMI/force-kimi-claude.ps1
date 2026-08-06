# Force Claude Code to use Kimi K2 via Moonshot AI
# This script tries multiple methods to make the override work

Write-Host "=== Forcing Claude Code to Use Kimi K2 ===" -ForegroundColor Cyan
Write-Host ""

# Method 1: Environment variables (must be set BEFORE starting)
Write-Host "Method 1: Setting environment variables..." -ForegroundColor Yellow
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/v1"
$env:ANTHROPIC_AUTH_TOKEN = "sk-KrTZIiWjc82pPFYNRIsg1kLMibCDnOtbU7ZA4etqYb9xV76k"

# Also try the /anthropic endpoint
$env:ANTHROPIC_BASE_URL_ALT = "https://api.moonshot.ai/anthropic"

Write-Host "  ANTHROPIC_BASE_URL: $env:ANTHROPIC_BASE_URL" -ForegroundColor Green
Write-Host "  ANTHROPIC_AUTH_TOKEN: [SET]" -ForegroundColor Green
Write-Host ""

# Method 2: Try with --settings flag
Write-Host "Method 2: Creating settings file..." -ForegroundColor Yellow
$settingsFile = Join-Path (Get-Location) "claude-settings.json"
$settings = @{
    api = @{
        baseUrl = "https://api.moonshot.ai/v1"
        apiKey = "sk-KrTZIiWjc82pPFYNRIsg1kLMibCDnOtbU7ZA4etqYb9xV76k"
    }
} | ConvertTo-Json -Depth 5

Set-Content -Path $settingsFile -Value $settings
Write-Host "  Created: $settingsFile" -ForegroundColor Green
Write-Host ""

# Method 3: Instructions
Write-Host "=== How to Use ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Option 1: With environment variables (current session):" -ForegroundColor Yellow
Write-Host "  claude" -ForegroundColor White
Write-Host ""
Write-Host "Option 2: With settings file:" -ForegroundColor Yellow
Write-Host "  claude --settings claude-settings.json" -ForegroundColor White
Write-Host ""
Write-Host "Option 3: Try different endpoint format:" -ForegroundColor Yellow
Write-Host "  `$env:ANTHROPIC_BASE_URL = 'https://api.moonshot.ai/v1'" -ForegroundColor White
Write-Host "  claude" -ForegroundColor White
Write-Host ""
Write-Host "Option 4: Try /anthropic endpoint:" -ForegroundColor Yellow
Write-Host "  `$env:ANTHROPIC_BASE_URL = 'https://api.moonshot.ai/anthropic'" -ForegroundColor White
Write-Host "  claude" -ForegroundColor White
Write-Host ""
Write-Host "=== Important ===" -ForegroundColor Red
Write-Host "1. CLOSE Claude Code if it's running" -ForegroundColor Yellow
Write-Host "2. Set variables BEFORE starting Claude Code" -ForegroundColor Yellow
Write-Host "3. Start Claude Code from THIS terminal" -ForegroundColor Yellow
Write-Host "4. Test with: claude --print 'What API are you using?'" -ForegroundColor Yellow
Write-Host ""
Write-Host "If it still doesn't work, Claude Code may not support API override." -ForegroundColor Yellow
Write-Host "In that case, use the direct Moonshot API scripts we created." -ForegroundColor Yellow





