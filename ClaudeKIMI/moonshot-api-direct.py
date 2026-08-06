#!/usr/bin/env python3
"""
Direct Moonshot AI API Client
Uses Kimi K2 models directly without Claude Code
"""

import requests
import json
import sys

# Moonshot AI Configuration
API_KEY = "sk-KrTZIiWjc82pPFYNRIsg1kLMibCDnOtbU7ZA4etqYb9xV76k"
BASE_URL = "https://api.moonshot.ai/v1"

# Available Kimi K2 models
MODELS = {
    "kimi-k2": "kimi-k2-0711-preview",
    "kimi-k2-thinking": "kimi-k2-thinking",
    "kimi-k2-turbo": "kimi-k2-turbo-preview",
    "kimi-latest": "kimi-latest"
}

def chat_with_kimi(prompt, model="kimi-k2-thinking", stream=False):
    """
    Send a message to Kimi K2 via Moonshot AI API
    """
    url = f"{BASE_URL}/chat/completions"
    
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    data = {
        "model": model,
        "messages": [
            {
                "role": "user",
                "content": prompt
            }
        ],
        "temperature": 0.7,
        "stream": stream
    }
    
    try:
        response = requests.post(url, headers=headers, json=data, timeout=30)
        response.raise_for_status()
        
        if stream:
            # Handle streaming response
            for line in response.iter_lines():
                if line:
                    decoded = line.decode('utf-8')
                    if decoded.startswith('data: '):
                        data_str = decoded[6:]
                        if data_str == '[DONE]':
                            break
                        try:
                            chunk = json.loads(data_str)
                            if 'choices' in chunk and len(chunk['choices']) > 0:
                                delta = chunk['choices'][0].get('delta', {})
                                if 'content' in delta:
                                    print(delta['content'], end='', flush=True)
                        except json.JSONDecodeError:
                            pass
            print()  # New line after streaming
        else:
            # Handle regular response
            result = response.json()
            if 'choices' in result and len(result['choices']) > 0:
                return result['choices'][0]['message']['content']
            else:
                return "No response from API"
                
    except requests.exceptions.RequestException as e:
        return f"Error: {str(e)}"

def list_models():
    """
    List available models from Moonshot AI
    """
    url = f"{BASE_URL}/models"
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        models = response.json()
        
        print("Available Moonshot AI Models:")
        print("-" * 50)
        for model in models.get('data', []):
            print(f"  - {model['id']}")
        return models
    except requests.exceptions.RequestException as e:
        print(f"Error listing models: {str(e)}")
        return None

def interactive_chat():
    """
    Interactive chat with Kimi K2
    """
    print("=" * 60)
    print("Kimi K2 Direct API Chat")
    print("=" * 60)
    print(f"Using model: {MODELS['kimi-k2-thinking']}")
    print("Type 'exit' to quit, 'models' to list models, 'switch <model>' to change model")
    print("=" * 60)
    print()
    
    current_model = MODELS['kimi-k2-thinking']
    conversation_history = []
    
    while True:
        try:
            user_input = input("You: ").strip()
            
            if not user_input:
                continue
                
            if user_input.lower() == 'exit':
                print("Goodbye!")
                break
                
            if user_input.lower() == 'models':
                list_models()
                continue
                
            if user_input.lower().startswith('switch '):
                model_name = user_input[7:].strip()
                if model_name in MODELS:
                    current_model = MODELS[model_name]
                    print(f"Switched to: {current_model}")
                else:
                    print(f"Unknown model. Available: {', '.join(MODELS.keys())}")
                continue
            
            # Add to conversation history
            conversation_history.append({
                "role": "user",
                "content": user_input
            })
            
            # Build messages for API
            messages = conversation_history.copy()
            
            print("Kimi K2: ", end='', flush=True)
            
            # Call API
            url = f"{BASE_URL}/chat/completions"
            headers = {
                "Authorization": f"Bearer {API_KEY}",
                "Content-Type": "application/json"
            }
            
            data = {
                "model": current_model,
                "messages": messages,
                "temperature": 0.7
            }
            
            response = requests.post(url, headers=headers, json=data, timeout=60)
            response.raise_for_status()
            result = response.json()
            
            if 'choices' in result and len(result['choices']) > 0:
                assistant_message = result['choices'][0]['message']['content']
                print(assistant_message)
                
                # Add to conversation history
                conversation_history.append({
                    "role": "assistant",
                    "content": assistant_message
                })
            else:
                print("No response from API")
                
            print()
            
        except KeyboardInterrupt:
            print("\nGoodbye!")
            break
        except Exception as e:
            print(f"Error: {str(e)}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        # Command line mode
        prompt = " ".join(sys.argv[1:])
        model = MODELS.get('kimi-k2-thinking', 'kimi-k2-0711-preview')
        response = chat_with_kimi(prompt, model)
        print(response)
    else:
        # Interactive mode
        interactive_chat()





