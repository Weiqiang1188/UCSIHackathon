# Setup PATH permanently with your specific path
# Your npm global bin path: C:\Users\weiqi\AppData\Roaming\npm

$yourPath = "C:\Users\weiqi\AppData\Roaming\npm"

Write-Host "Setting up PATH with your specific path: $yourPath" -ForegroundColor Cyan

# Add to PATH for current session
$env:PATH = "$yourPath;$env:PATH"
Write-Host "Added to PATH for current session" -ForegroundColor Green

# Make it permanent - add to PowerShell profile
if (!(Test-Path $PROFILE)) { 
    New-Item -Path $PROFILE -Type File -Force | Out-Null
    Write-Host "Created PowerShell profile: $PROFILE" -ForegroundColor Green
}

$profileLine = "`$env:PATH = `"$yourPath;`$env:PATH`""
$profileContent = Get-Content $PROFILE -ErrorAction SilentlyContinue

if ($profileContent -notcontains $profileLine) {
    Add-Content -Path $PROFILE -Value $profileLine
    Write-Host "Added to PowerShell profile" -ForegroundColor Green
} else {
    Write-Host "Already in profile" -ForegroundColor Yellow
}

# Reload profile
. $PROFILE
Write-Host "Profile reloaded" -ForegroundColor Green

# Verify
Write-Host ""
Write-Host "Verification:" -ForegroundColor Cyan
if ($env:PATH -like "*$yourPath*") {
    Write-Host "  PATH contains your npm bin directory" -ForegroundColor Green
} else {
    Write-Host "  PATH does not contain your npm bin directory" -ForegroundColor Red
}

Write-Host ""
Write-Host "Setup complete! Your PATH is now configured permanently." -ForegroundColor Green

