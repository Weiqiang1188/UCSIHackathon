# Moonshot AI API Direct Access (PowerShell)
# Uses Kimi K2 models directly via HTTP requests

$apiKey = "sk-KrTZIiWjc82pPFYNRIsg1kLMibCDnOtbU7ZA4etqYb9xV76k"
$baseUrl = "https://api.moonshot.ai/v1"

function Invoke-KimiChat {
    param(
        [string]$Prompt,
        [string]$Model = "kimi-k2-thinking"
    )
    
    $url = "$baseUrl/chat/completions"
    
    $headers = @{
        "Authorization" = "Bearer $apiKey"
        "Content-Type" = "application/json"
    }
    
    $body = @{
        model = $Model
        messages = @(
            @{
                role = "user"
                content = $Prompt
            }
        )
        temperature = 0.7
    } | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json"
        
        if ($response.choices -and $response.choices.Count -gt 0) {
            return $response.choices[0].message.content
        } else {
            return "No response from API"
        }
    } catch {
        return "Error: $($_.Exception.Message)"
    }
}

function Get-KimiModels {
    $url = "$baseUrl/models"
    $headers = @{
        "Authorization" = "Bearer $apiKey"
        "Content-Type" = "application/json"
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        Write-Host "Available Moonshot AI Models:" -ForegroundColor Cyan
        Write-Host "-" * 50 -ForegroundColor Gray
        $response.data | ForEach-Object {
            Write-Host "  - $($_.id)" -ForegroundColor White
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Example usage
Write-Host "=== Moonshot AI Direct API ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Functions available:" -ForegroundColor Yellow
Write-Host "  Invoke-KimiChat -Prompt 'Your question here'" -ForegroundColor White
Write-Host "  Get-KimiModels" -ForegroundColor White
Write-Host ""
Write-Host "Example:" -ForegroundColor Yellow
Write-Host '  Invoke-KimiChat -Prompt "Hello, are you Kimi K2?"' -ForegroundColor White
Write-Host ""

# Test connection
Write-Host "Testing connection..." -ForegroundColor Yellow
$testResponse = Invoke-KimiChat -Prompt "Say 'Hello, I am Kimi K2' if you are working correctly."
Write-Host "Response: $testResponse" -ForegroundColor Green





