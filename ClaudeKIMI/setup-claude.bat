@echo off
REM Claude CLI Setup Script for Windows (Batch)
REM This script configures Claude CLI with your Moonshot AI endpoint

echo Setting up Claude CLI...

REM Add Claude CLI to PATH for current session
set "CLAUDE_PATH=%USERPROFILE%\.local\bin"
set "PATH=%PATH%;%CLAUDE_PATH%"

REM Set environment variables for Moonshot AI endpoint
set "ANTHROPIC_BASE_URL=https://api.moonshot.ai/anthropic"
set "ANTHROPIC_AUTH_TOKEN=sk-RNVgHcIvFy4UmRet4j7gSGs5lTB9XmwBqEscC9ydHJ00tGsu"

echo Environment variables set:
echo   ANTHROPIC_BASE_URL=%ANTHROPIC_BASE_URL%
echo   ANTHROPIC_AUTH_TOKEN=[HIDDEN]

echo.
echo Verifying Claude CLI installation...
claude --version
if errorlevel 1 (
    echo Warning: Claude CLI not found in PATH
    echo You may need to restart your terminal or add %CLAUDE_PATH% to your system PATH permanently
)

echo.
echo Setup complete! You can now run 'claude' to start using the CLI.
echo Note: Standard Claude CLI uses web authentication. For custom endpoints,
echo you may need to use the Anthropic Python SDK or other tools.

