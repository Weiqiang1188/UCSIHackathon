# Quick verification script

Write-Host "=== Quick Kimi K2 Verification ===" -ForegroundColor Cyan
Write-Host ""

# Set variables
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"
$env:ANTHROPIC_AUTH_TOKEN = "sk-KrTZIiWjc82pPFYNRIsg1kLMibCDnOtbU7ZA4etqYb9xV76k"

Write-Host "Testing with a simple question..." -ForegroundColor Yellow
Write-Host ""

$response = claude --print "What AI model are you? Say your exact model name." 2>&1

Write-Host "Response:" -ForegroundColor Cyan
Write-Host $response
Write-Host ""

# Check for indicators
if ($response -like "*kimi*" -or $response -like "*Kimi*" -or $response -like "*moonshot*" -or $response -like "*Moonshot*") {
    Write-Host "[SUCCESS] Response mentions Kimi/Moonshot!" -ForegroundColor Green
    Write-Host "You are likely using Kimi K2!" -ForegroundColor Green
} elseif ($response -like "*claude*" -or $response -like "*anthropic*") {
    Write-Host "[WARNING] Response mentions Claude/Anthropic" -ForegroundColor Yellow
    Write-Host "Might still be using default Claude" -ForegroundColor Yellow
} else {
    Write-Host "[INFO] Could not determine from response" -ForegroundColor Yellow
    Write-Host "Check the API endpoint configuration" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "To check which specific Kimi K2 model:" -ForegroundColor Cyan
Write-Host "  Look for mentions of:" -ForegroundColor Yellow
Write-Host "    - kimi-k2-thinking" -ForegroundColor White
Write-Host "    - kimi-k2-0711-preview" -ForegroundColor White
Write-Host "    - kimi-k2-turbo-preview" -ForegroundColor White

