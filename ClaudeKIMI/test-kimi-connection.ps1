# Test if Claude Code is actually using Kimi K2

Write-Host "=== Testing Kimi K2 Connection ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Ask Claude Code which model it's using
Write-Host "Test 1: Asking Claude Code about its model..." -ForegroundColor Yellow
Write-Host "Running: claude --print 'What model are you? What is your name and version?'" -ForegroundColor Gray
Write-Host ""

$test1 = claude --print "What model are you? What is your name and version?" 2>&1
Write-Host "Response:" -ForegroundColor Cyan
Write-Host $test1
Write-Host ""

# Test 2: Ask about Moonshot/Kimi
Write-Host "Test 2: Asking about Moonshot AI..." -ForegroundColor Yellow
Write-Host "Running: claude --print 'Are you connected to Moonshot AI? What API endpoint are you using?'" -ForegroundColor Gray
Write-Host ""

$test2 = claude --print "Are you connected to Moonshot AI? What API endpoint are you using?" 2>&1
Write-Host "Response:" -ForegroundColor Cyan
Write-Host $test2
Write-Host ""

# Test 3: Check environment variables
Write-Host "Test 3: Checking environment configuration..." -ForegroundColor Yellow
Write-Host "ANTHROPIC_BASE_URL: $env:ANTHROPIC_BASE_URL" -ForegroundColor Cyan
Write-Host "ANTHROPIC_AUTH_TOKEN: $(if ($env:ANTHROPIC_AUTH_TOKEN) { '[SET - starts with ' + $env:ANTHROPIC_AUTH_TOKEN.Substring(0,5) + '...]' } else { '[NOT SET]' })" -ForegroundColor Cyan
Write-Host ""

# Summary
Write-Host "=== How to Tell if Kimi K2 is Active ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Check the response - Kimi K2 might mention:" -ForegroundColor Yellow
Write-Host "   - 'Kimi' or 'Moonshot AI'" -ForegroundColor White
Write-Host "   - Different response style than Claude" -ForegroundColor White
Write-Host ""
Write-Host "2. Check API endpoint:" -ForegroundColor Yellow
Write-Host "   - Should be: https://api.moonshot.ai/anthropic" -ForegroundColor White
Write-Host "   - NOT: https://api.anthropic.com" -ForegroundColor White
Write-Host ""
Write-Host "3. Test with a coding question:" -ForegroundColor Yellow
Write-Host "   Kimi K2 performs better on coding tasks" -ForegroundColor White
Write-Host "   (53.7% vs 47.4% on LiveCodeBench)" -ForegroundColor White
Write-Host ""

