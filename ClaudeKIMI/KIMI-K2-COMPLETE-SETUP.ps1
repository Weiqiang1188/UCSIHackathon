# ============================================================================
# Kimi K2 + Claude Code Complete Setup Guide (PowerShell for Windows)
# Based on: https://github.com/ShenSeanChen/yt-kimi-k2-claude.git
# ============================================================================

Write-Host "`n=== Kimi K2 + Claude Code Integration Setup ===" -ForegroundColor Cyan
Write-Host "This setup redirects Claude Code to use Moonshot AI's Kimi K2 model`n" -ForegroundColor Yellow

# ============================================================================
# Step 1: Install Claude Code
# ============================================================================
Write-Host "[Step 1/5] Installing Claude Code globally..." -ForegroundColor Yellow
Write-Host "Why: Claude Code is Anthropic's official CLI tool for AI-assisted coding" -ForegroundColor Gray
Write-Host "     The -g flag installs it globally, making the claude command available system-wide`n" -ForegroundColor Gray

npm install -g @anthropic-ai/claude-code
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Installation failed" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Claude Code installed successfully`n" -ForegroundColor Green

# ============================================================================
# Step 2: Fix PATH Configuration
# ============================================================================
Write-Host "[Step 2/5] Fixing PATH configuration..." -ForegroundColor Yellow
Write-Host "Why: npm installed Claude Code to a custom directory" -ForegroundColor Gray
Write-Host "     Without PATH configuration, the shell can't find the claude command`n" -ForegroundColor Gray

# Check where npm installed Claude Code
Write-Host "Checking npm installation location..." -ForegroundColor Cyan
$npmLocation = npm list -g @anthropic-ai/claude-code 2>&1 | Select-String "npm" | Select-Object -First 1
Write-Host "  Location: $npmLocation" -ForegroundColor Gray

# Get the actual npm global bin path
$npmBinPath = "C:\Users\weiqi\AppData\Roaming\npm"

# Add to PATH for current session (temporary fix)
$env:PATH = "$npmBinPath;$env:PATH"
Write-Host "✓ Added to PATH for current session" -ForegroundColor Green

# Permanent fix - add to PowerShell profile
Write-Host "Adding to PowerShell profile for permanent access..." -ForegroundColor Cyan
if (!(Test-Path $PROFILE)) { 
    New-Item -Path $PROFILE -Type File -Force | Out-Null
    Write-Host "  Created PowerShell profile: $PROFILE" -ForegroundColor Gray
}

$profileLine = '$env:PATH = "C:\Users\weiqi\AppData\Roaming\npm;$env:PATH"'
$profileContent = Get-Content $PROFILE -ErrorAction SilentlyContinue

if ($profileContent -notcontains $profileLine) {
    Add-Content -Path $PROFILE -Value $profileLine
    Write-Host "✓ Added PATH to PowerShell profile" -ForegroundColor Green
} else {
    Write-Host "✓ PATH already in profile" -ForegroundColor Green
}

# Reload profile
. $PROFILE

# Verify it works
Write-Host "`nVerifying installation..." -ForegroundColor Cyan
$version = claude --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Claude CLI version: $version`n" -ForegroundColor Green
} else {
    Write-Host "✗ Claude CLI not accessible. Please restart your terminal.`n" -ForegroundColor Red
}

# ============================================================================
# Step 3: Bypass Region Restrictions
# ============================================================================
Write-Host "[Step 3/5] Bypassing region restrictions..." -ForegroundColor Yellow
Write-Host "Why: Claude Code normally performs region/country verification" -ForegroundColor Gray
Write-Host "     Setting hasCompletedOnboarding: true bypasses this check`n" -ForegroundColor Gray

$homeDir = $env:USERPROFILE
$configPath = Join-Path $homeDir ".claude.json"

# Create/update the config file
$config = @{}
if (Test-Path $configPath) {
    try {
        $existingContent = Get-Content $configPath -Raw | ConvertFrom-Json
        $existingContent.PSObject.Properties | ForEach-Object {
            $config[$_.Name] = $_.Value
        }
        Write-Host "  Found existing config, updating..." -ForegroundColor Gray
    } catch {
        Write-Host "  Warning: Could not parse existing config, creating new one" -ForegroundColor Yellow
    }
}

# Set the onboarding flag
$config.hasCompletedOnboarding = $true

# Write the config file
$jsonContent = $config | ConvertTo-Json -Depth 10
Set-Content -Path $configPath -Value $jsonContent

Write-Host "✓ Config file created/updated: $configPath" -ForegroundColor Green
Write-Host "  Content: hasCompletedOnboarding = true`n" -ForegroundColor Gray

# ============================================================================
# Step 4: Configure Kimi K2 API Access
# ============================================================================
Write-Host "[Step 4/5] Configuring Kimi K2 API access..." -ForegroundColor Yellow
Write-Host "Why: Redirects API calls to Moonshot's servers instead of Anthropic's" -ForegroundColor Gray
Write-Host "     This allows Claude Code's interface to work with Kimi K2's backend`n" -ForegroundColor Gray

# Set environment variables for current session
$env:ANTHROPIC_AUTH_TOKEN = "sk-RNVgHcIvFy4UmRet4j7gSGs5lTB9XmwBqEscC9ydHJ00tGsu"
$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"

Write-Host "✓ Environment variables set for current session:" -ForegroundColor Green
Write-Host "  ANTHROPIC_BASE_URL: $env:ANTHROPIC_BASE_URL" -ForegroundColor Cyan
Write-Host "  ANTHROPIC_AUTH_TOKEN: [SET]" -ForegroundColor Cyan

# Make it permanent - add to PowerShell profile
Write-Host "`nAdding to PowerShell profile for permanent access..." -ForegroundColor Cyan
$tokenLine = '$env:ANTHROPIC_AUTH_TOKEN = "sk-RNVgHcIvFy4UmRet4j7gSGs5lTB9XmwBqEscC9ydHJ00tGsu"'
$urlLine = '$env:ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic"'

$profileContent = Get-Content $PROFILE -ErrorAction SilentlyContinue

if ($profileContent -notcontains $tokenLine) {
    Add-Content -Path $PROFILE -Value $tokenLine
    Write-Host "  ✓ Added ANTHROPIC_AUTH_TOKEN to profile" -ForegroundColor Green
} else {
    Write-Host "  ✓ ANTHROPIC_AUTH_TOKEN already in profile" -ForegroundColor Green
}

if ($profileContent -notcontains $urlLine) {
    Add-Content -Path $PROFILE -Value $urlLine
    Write-Host "  ✓ Added ANTHROPIC_BASE_URL to profile" -ForegroundColor Green
} else {
    Write-Host "  ✓ ANTHROPIC_BASE_URL already in profile" -ForegroundColor Green
}

Write-Host ""

# ============================================================================
# Step 5: Test the Setup
# ============================================================================
Write-Host "[Step 5/5] Testing the setup..." -ForegroundColor Yellow
Write-Host "Why: Verifies that all configuration steps worked correctly`n" -ForegroundColor Gray

Write-Host "Final verification:" -ForegroundColor Cyan
Write-Host "  ✓ Claude CLI: $(claude --version)" -ForegroundColor Green
Write-Host "  ✓ PATH configured: $(if ($env:PATH -like "*AppData\Roaming\npm*") { 'Yes' } else { 'No' })" -ForegroundColor Green
Write-Host "  ✓ API URL: $env:ANTHROPIC_BASE_URL" -ForegroundColor Green
Write-Host "  ✓ Config file: $(if (Test-Path $configPath) { 'Exists' } else { 'Missing' })" -ForegroundColor Green

# ============================================================================
# Summary
# ============================================================================
Write-Host "`n=== Setup Complete! ===" -ForegroundColor Green
Write-Host "`nTechnical Architecture:" -ForegroundColor Cyan
Write-Host "  Your Terminal" -ForegroundColor White
Write-Host "      ↓" -ForegroundColor Gray
Write-Host "  Claude Code CLI (Anthropic's interface)" -ForegroundColor White
Write-Host "      ↓" -ForegroundColor Gray
Write-Host "  ANTHROPIC_BASE_URL redirect" -ForegroundColor White
Write-Host "      ↓" -ForegroundColor Gray
Write-Host "  Moonshot AI API (api.moonshot.ai)" -ForegroundColor White
Write-Host "      ↓" -ForegroundColor Gray
Write-Host "  Kimi K2 Model (1T parameters, MoE architecture)" -ForegroundColor White

Write-Host "`nTo start using Claude Code with Kimi K2:" -ForegroundColor Yellow
Write-Host "  claude" -ForegroundColor White

Write-Host "`nNote: If you opened a new terminal, environment variables are already" -ForegroundColor Gray
Write-Host "      set in your PowerShell profile. Just run 'claude' to start!`n" -ForegroundColor Gray

