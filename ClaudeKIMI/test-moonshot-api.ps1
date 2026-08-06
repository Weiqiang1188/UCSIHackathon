# Test if Moonshot AI API key works and has credits

Write-Host "=== Testing Moonshot AI API Key ===" -ForegroundColor Cyan
Write-Host ""

$apiKey = "sk-RNVgHcIvFy4UmRet4j7gSGs5lTB9XmwBqEscC9ydHJ00tGsu"
$apiUrl = "https://api.moonshot.ai/v1/models"

Write-Host "Testing API connection..." -ForegroundColor Yellow
Write-Host "Endpoint: $apiUrl" -ForegroundColor Gray
Write-Host ""

try {
    $headers = @{
        "Authorization" = "Bearer $apiKey"
        "Content-Type" = "application/json"
    }
    
    $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers -ErrorAction Stop
    
    Write-Host "[SUCCESS] API key is valid!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Available models:" -ForegroundColor Cyan
    $response.data | ForEach-Object {
        Write-Host "  - $($_.id)" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "You can use Claude Code with Kimi K2!" -ForegroundColor Green
    
} catch {
    $errorMessage = $_.Exception.Message
    Write-Host "[ERROR] API test failed" -ForegroundColor Red
    Write-Host "Error: $errorMessage" -ForegroundColor Red
    Write-Host ""
    
    if ($errorMessage -like "*401*" -or $errorMessage -like "*Unauthorized*") {
        Write-Host "This usually means:" -ForegroundColor Yellow
        Write-Host "  - API key is invalid" -ForegroundColor White
        Write-Host "  - API key has expired" -ForegroundColor White
    } elseif ($errorMessage -like "*429*" -or $errorMessage -like "*quota*" -or $errorMessage -like "*balance*") {
        Write-Host "This usually means:" -ForegroundColor Yellow
        Write-Host "  - No credits/balance in your account" -ForegroundColor White
        Write-Host "  - You need to top up your Moonshot AI account" -ForegroundColor White
    } else {
        Write-Host "This might mean:" -ForegroundColor Yellow
        Write-Host "  - Network connection issue" -ForegroundColor White
        Write-Host "  - API endpoint issue" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "To top up your Moonshot AI account:" -ForegroundColor Cyan
    Write-Host "  1. Go to: https://platform.moonshot.cn/" -ForegroundColor White
    Write-Host "  2. Log in to your account" -ForegroundColor White
    Write-Host "  3. Go to billing/credits section" -ForegroundColor White
    Write-Host "  4. Add credits to your account" -ForegroundColor White
}

