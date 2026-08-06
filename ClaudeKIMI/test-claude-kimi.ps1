# Test Claude Code with Kimi K2
# You're already in the project directory, so just run this!

Write-Host "=== Testing Claude Code with Kimi K2 ===" -ForegroundColor Cyan
Write-Host ""

# Make sure environment variables are set
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"
$env:ANTHROPIC_AUTH_TOKEN = "sk-KrTZIiWjc82pPFYNRIsg1kLMibCDnOtbU7ZA4etqYb9xV76k"

Write-Host "Environment variables set:" -ForegroundColor Green
Write-Host "  API URL: $env:ANTHROPIC_BASE_URL" -ForegroundColor Cyan
Write-Host "  API Token: [SET]" -ForegroundColor Cyan
Write-Host ""

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow
Write-Host ""

Write-Host "Starting Claude Code..." -ForegroundColor Yellow
Write-Host "You can now test if Kimi K2 is working!" -ForegroundColor Green
Write-Host ""

# Start Claude Code
claude

