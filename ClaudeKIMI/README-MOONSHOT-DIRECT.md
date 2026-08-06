# 🚀 Using Moonshot AI API Directly

Since Claude Code doesn't support API redirection, here's how to use Moonshot AI (Kimi K2) directly.

## 📋 Prerequisites

1. **Python 3.8+** (for Python script)
2. **PowerShell** (for PowerShell script)
3. **Moonshot AI API Key**: `sk-KrTZIiWjc82pPFYNRIsg1kLMibCDnOtbU7ZA4etqYb9xV76k`

## 🐍 Method 1: Python Script (Recommended)

### Installation

```powershell
# Install required package
pip install requests
```

### Usage

**Interactive Chat:**
```powershell
python moonshot-api-direct.py
```

**Command Line:**
```powershell
python moonshot-api-direct.py "Hello, are you Kimi K2?"
```

**Features:**
- Interactive chat mode
- Multiple Kimi K2 models (kimi-k2-thinking, kimi-k2, kimi-k2-turbo)
- Conversation history
- Model switching

## 💻 Method 2: PowerShell Script

### Usage

```powershell
# Load the script
. .\moonshot-api-powershell.ps1

# Chat with Kimi K2
Invoke-KimiChat -Prompt "Hello, are you Kimi K2?"

# List available models
Get-KimiModels
```

## 🔧 Method 3: Direct HTTP Requests

### Using curl (if available)

```powershell
curl -X POST "https://api.moonshot.ai/v1/chat/completions" `
  -H "Authorization: Bearer sk-KrTZIiWjc82pPFYNRIsg1kLMibCDnOtbU7ZA4etqYb9xV76k" `
  -H "Content-Type: application/json" `
  -d '{
    "model": "kimi-k2-thinking",
    "messages": [
      {
        "role": "user",
        "content": "Hello, are you Kimi K2?"
      }
    ]
  }'
```

### Using PowerShell Invoke-RestMethod

```powershell
$headers = @{
    "Authorization" = "Bearer sk-KrTZIiWjc82pPFYNRIsg1kLMibCDnOtbU7ZA4etqYb9xV76k"
    "Content-Type" = "application/json"
}

$body = @{
    model = "kimi-k2-thinking"
    messages = @(
        @{
            role = "user"
            content = "Hello, are you Kimi K2?"
        }
    )
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "https://api.moonshot.ai/v1/chat/completions" -Method Post -Headers $headers -Body $body
$response.choices[0].message.content
```

## 📊 Available Kimi K2 Models

- `kimi-k2-0711-preview` - Standard Kimi K2
- `kimi-k2-thinking` - Kimi K2 with reasoning capabilities
- `kimi-k2-turbo-preview` - Faster version
- `kimi-latest` - Latest Kimi model
- `kimi-k2-0905-preview` - Another preview version

## 🎯 Quick Start

1. **Install Python dependencies:**
   ```powershell
   pip install requests
   ```

2. **Run interactive chat:**
   ```powershell
   python moonshot-api-direct.py
   ```

3. **Or use PowerShell:**
   ```powershell
   . .\moonshot-api-powershell.ps1
   Invoke-KimiChat -Prompt "Your question here"
   ```

## 🔍 Why This Approach?

- ✅ **Direct API access** - No need to override Claude Code
- ✅ **Full control** - Choose any Kimi K2 model
- ✅ **Reliable** - Works consistently
- ✅ **Simple** - Easy to use and understand

## 📝 Example Usage

```python
# Python
from moonshot_api_direct import chat_with_kimi

response = chat_with_kimi("What is 2+2?", model="kimi-k2-thinking")
print(response)
```

```powershell
# PowerShell
. .\moonshot-api-powershell.ps1
$response = Invoke-KimiChat -Prompt "What is 2+2?" -Model "kimi-k2-thinking"
Write-Host $response
```

## 🎉 Benefits

- Direct access to Kimi K2 models
- No dependency on Claude Code
- Full API control
- Works reliably
- Easy to integrate into your projects





