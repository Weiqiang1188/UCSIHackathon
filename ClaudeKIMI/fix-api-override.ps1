# Fix API override - Force Claude Code to use Moonshot AI

Write-Host "=== Fixing API Override ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Set environment variables
Write-Host "1. Setting environment variables..." -ForegroundColor Yellow
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"
$env:ANTHROPIC_AUTH_TOKEN = "sk-KrTZIiWjc82pPFYNRIsg1kLMibCDnOtbU7ZA4etqYb9xV76k"

Write-Host "   ANTHROPIC_BASE_URL: $env:ANTHROPIC_BASE_URL" -ForegroundColor Green
Write-Host "   ANTHROPIC_AUTH_TOKEN: [SET]" -ForegroundColor Green
Write-Host ""

# Step 2: Verify variables are set
Write-Host "2. Verifying variables..." -ForegroundColor Yellow
if ($env:ANTHROPIC_BASE_URL -eq "https://api.moonshot.ai/anthropic") {
    Write-Host "   [OK] Base URL is correct" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] Base URL is wrong!" -ForegroundColor Red
    exit 1
}

if ($env:ANTHROPIC_AUTH_TOKEN) {
    Write-Host "   [OK] API token is set" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] API token not set!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 3: Check if Claude Code is running
Write-Host "3. Important instructions:" -ForegroundColor Yellow
Write-Host "   - CLOSE Claude Code if it's running" -ForegroundColor White
Write-Host "   - Environment variables must be set BEFORE starting Claude Code" -ForegroundColor White
Write-Host "   - Start Claude Code from THIS terminal session" -ForegroundColor White
Write-Host ""

# Step 4: Test API connection
Write-Host "4. Testing Moonshot AI connection..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $env:ANTHROPIC_AUTH_TOKEN"
        "Content-Type" = "application/json"
    }
    $testUrl = "https://api.moonshot.ai/v1/models"
    $response = Invoke-RestMethod -Uri $testUrl -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "   [OK] Moonshot AI connection works!" -ForegroundColor Green
    Write-Host "   Available models: $($response.data.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "   [WARNING] Could not test connection: $($_.Exception.Message)" -ForegroundColor Yellow
}
Write-Host ""

# Step 5: Instructions
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Close Claude Code if running" -ForegroundColor Yellow
Write-Host "2. Run this command to start Claude Code:" -ForegroundColor Yellow
Write-Host "   claude" -ForegroundColor White
Write-Host ""
Write-Host "3. Or test with a print command:" -ForegroundColor Yellow
Write-Host '   claude --print "What API endpoint are you using?"' -ForegroundColor White
Write-Host ""
Write-Host "4. The response should mention Moonshot AI, not Anthropic" -ForegroundColor Yellow
Write-Host ""
Write-Host "Note: If it still shows Anthropic, Claude Code might:" -ForegroundColor Yellow
Write-Host "  - Have cached configuration" -ForegroundColor White
Write-Host "  - Need to be restarted completely" -ForegroundColor White
Write-Host "  - Require different configuration method" -ForegroundColor White





