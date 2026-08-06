# Quick script to find your npm global bin path

Write-Host "=== Finding Your npm Global Bin Path ===" -ForegroundColor Cyan
Write-Host ""

# Method 1: npm config
Write-Host "Method 1: Using npm config" -ForegroundColor Yellow
$npmPrefix = npm config get prefix
Write-Host "  Your npm global bin path: $npmPrefix" -ForegroundColor Green
Write-Host ""

# Method 2: Check where claude is installed
Write-Host "Method 2: Check where Claude is installed" -ForegroundColor Yellow
$claudePath = where.exe claude 2>$null
if ($claudePath) {
    $claudeDir = Split-Path $claudePath[0] -Parent
    Write-Host "  Claude found at: $claudeDir" -ForegroundColor Green
} else {
    Write-Host "  Claude not found in PATH" -ForegroundColor Red
}
Write-Host ""

# Method 3: Check npm global packages
Write-Host "Method 3: Check npm global packages location" -ForegroundColor Yellow
$npmRoot = npm root -g
Write-Host "  npm global root: $npmRoot" -ForegroundColor Green
Write-Host "  (Bin path is usually the parent directory)" -ForegroundColor Gray
Write-Host ""

# Summary
Write-Host "=== Your Path ===" -ForegroundColor Cyan
Write-Host "Use this path in your setup: $npmPrefix" -ForegroundColor Green
Write-Host ""
Write-Host "This is the path you need to add to your PATH environment variable." -ForegroundColor Yellow

