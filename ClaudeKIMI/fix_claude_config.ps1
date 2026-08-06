# Fix Claude Config Script (PowerShell)
# This script creates/updates the .claude.json config file

$homeDir = $env:USERPROFILE
$filePath = Join-Path $homeDir ".claude.json"

Write-Host "Fixing Claude config at: $filePath" -ForegroundColor Yellow

# Read existing config if it exists
$config = @{}
if (Test-Path $filePath) {
    try {
        $existingContent = Get-Content $filePath -Raw | ConvertFrom-Json
        $config = @{}
        $existingContent.PSObject.Properties | ForEach-Object {
            $config[$_.Name] = $_.Value
        }
    } catch {
        Write-Host "Warning: Could not parse existing config, creating new one" -ForegroundColor Yellow
    }
}

# Set the onboarding flag
$config.hasCompletedOnboarding = $true

# Write the config file
$jsonContent = $config | ConvertTo-Json -Depth 10
Set-Content -Path $filePath -Value $jsonContent

Write-Host "Config file updated successfully!" -ForegroundColor Green
Write-Host "Content:" -ForegroundColor Cyan
Get-Content $filePath

