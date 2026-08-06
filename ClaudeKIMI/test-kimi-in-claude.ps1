# Test if Claude Code can use Kimi K2
# Try different endpoint formats and methods

Write-Host "=== Testing Kimi K2 in Claude Code ===" -ForegroundColor Cyan
Write-Host ""

# Close any running Claude Code instances
Write-Host "Step 1: Make sure Claude Code is CLOSED" -ForegroundColor Yellow
Write-Host "  (Close it now if it's running)" -ForegroundColor Gray
Write-Host ""

# Try Method 1: /v1 endpoint (suggested by web search)
Write-Host "Step 2: Setting environment variables with /v1 endpoint..." -ForegroundColor Yellow
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/v1"
$env:ANTHROPIC_AUTH_TOKEN = "sk-KrTZIiWjc82pPFYNRIsg1kLMibCDnOtbU7ZA4etqYb9xV76k"

Write-Host "  ANTHROPIC_BASE_URL: $env:ANTHROPIC_BASE_URL" -ForegroundColor Green
Write-Host "  ANTHROPIC_AUTH_TOKEN: [SET]" -ForegroundColor Green
Write-Host ""

# Test the connection
Write-Host "Step 3: Testing with Claude Code..." -ForegroundColor Yellow
Write-Host "  Running: claude --print 'What API endpoint are you using?'" -ForegroundColor Gray
Write-Host ""

$testResult = claude --print "What API endpoint are you using? Are you connected to Moonshot AI or Anthropic?" 2>&1

Write-Host "Response:" -ForegroundColor Cyan
Write-Host $testResult
Write-Host ""

# Check if it mentions Moonshot
if ($testResult -like "*moonshot*" -or $testResult -like "*Moonshot*" -or $testResult -like "*kimi*" -or $testResult -like "*Kimi*") {
    Write-Host "[SUCCESS] Claude Code is using Moonshot AI!" -ForegroundColor Green
} elseif ($testResult -like "*anthropic*" -or $testResult -like "*Anthropic*" -or $testResult -like "*claude*" -or $testResult -like "*Claude*") {
    Write-Host "[FAILED] Still using Anthropic API" -ForegroundColor Red
    Write-Host ""
    Write-Host "Trying alternative endpoint format..." -ForegroundColor Yellow
    $env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"
    Write-Host "  Changed to: $env:ANTHROPIC_BASE_URL" -ForegroundColor Cyan
    Write-Host "  Try running Claude Code again" -ForegroundColor Yellow
} else {
    Write-Host "[UNCLEAR] Could not determine from response" -ForegroundColor Yellow
    Write-Host "  Check the response above manually" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "If it's working:" -ForegroundColor Green
Write-Host "  claude" -ForegroundColor White
Write-Host ""
Write-Host "If it's NOT working:" -ForegroundColor Red
Write-Host "  Claude Code may not support API override" -ForegroundColor Yellow
Write-Host "  Use: python moonshot-api-direct.py (direct API access)" -ForegroundColor White





