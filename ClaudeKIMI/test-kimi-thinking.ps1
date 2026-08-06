# Test if Claude Code is using Kimi K2 Thinking model

Write-Host "=== Testing Kimi K2 Thinking Model ===" -ForegroundColor Cyan
Write-Host ""

# Set environment variables
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"
$env:ANTHROPIC_AUTH_TOKEN = "sk-KrTZIiWjc82pPFYNRIsg1kLMibCDnOtbU7ZA4etqYb9xV76k"

Write-Host "1. Checking API configuration..." -ForegroundColor Yellow
Write-Host "   API URL: $env:ANTHROPIC_BASE_URL" -ForegroundColor Cyan
if ($env:ANTHROPIC_BASE_URL -eq "https://api.moonshot.ai/anthropic") {
    Write-Host "   [OK] Correctly set to Moonshot AI" -ForegroundColor Green
} else {
    Write-Host "   [WRONG] Not set to Moonshot AI" -ForegroundColor Red
}
Write-Host ""

Write-Host "2. Testing Claude Code connection..." -ForegroundColor Yellow
Write-Host "   Asking: 'What model are you? Are you Kimi K2?'" -ForegroundColor Gray
Write-Host ""

# Test 1: Ask directly about the model
Write-Host "Test 1: Direct model question" -ForegroundColor Cyan
$test1 = claude --print "What model are you? Are you Kimi K2? What is your full model name?" 2>&1
Write-Host $test1
Write-Host ""

# Test 2: Ask about API endpoint
Write-Host "Test 2: API endpoint question" -ForegroundColor Cyan
$test2 = claude --print "What API endpoint are you connected to? Are you using Moonshot AI?" 2>&1
Write-Host $test2
Write-Host ""

# Test 3: Ask about thinking capabilities (Kimi K2 Thinking specific)
Write-Host "Test 3: Thinking capabilities" -ForegroundColor Cyan
$test3 = claude --print "Do you have thinking/reasoning capabilities? Can you show your thinking process?" 2>&1
Write-Host $test3
Write-Host ""

Write-Host "=== How to Identify Kimi K2 Thinking ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Kimi K2 Thinking model characteristics:" -ForegroundColor Yellow
Write-Host "  1. Model name might mention: 'kimi-k2-thinking' or 'Kimi K2'" -ForegroundColor White
Write-Host "  2. API endpoint: Should be Moonshot AI (api.moonshot.ai)" -ForegroundColor White
Write-Host "  3. Response style: May show reasoning/thinking process" -ForegroundColor White
Write-Host "  4. Better at complex reasoning tasks" -ForegroundColor White
Write-Host ""
Write-Host "If you see 'Sonnet 4.5' in the UI, it's just a label." -ForegroundColor Yellow
Write-Host "The actual API calls should go to Moonshot AI." -ForegroundColor Yellow
Write-Host ""
Write-Host "To verify, check the responses above for:" -ForegroundColor Yellow
Write-Host "  - Mentions of 'Kimi' or 'Moonshot'" -ForegroundColor White
Write-Host "  - API endpoint confirmation" -ForegroundColor White
Write-Host "  - Different response style than standard Claude" -ForegroundColor White

