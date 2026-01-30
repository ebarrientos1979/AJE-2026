#!/usr/bin/env python3
import requests
import json
import sys

def test_api():
    # Get API URL from Terraform output
    try:
        import subprocess
        result = subprocess.run(['terraform', 'output', '-raw', 'api_url'], 
                              capture_output=True, text=True, cwd='.')
        api_url = result.stdout.strip()
    except:
        print("Error: Could not get API URL from Terraform output")
        print("Make sure you've run 'terraform apply' first")
        sys.exit(1)
    
    print(f"Testing API: {api_url}")
    
    # Test queries
    test_queries = [
        "¿Qué productos de abarrotes tienen disponibles?",
        "¿Cuáles son los precios de los productos?",
        "¿Cómo puedo hacer un pedido?",
        "¿Qué información tienen sobre delivery?"
    ]
    
    for query in test_queries:
        print(f"\n🔍 Query: {query}")
        
        try:
            response = requests.post(
                api_url,
                headers={'Content-Type': 'application/json'},
                json={'query': query},
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                print(f"✅ Response: {data['response'][:200]}...")
                print(f"📊 Sources: {data['sources_count']}")
            else:
                print(f"❌ Error {response.status_code}: {response.text}")
                
        except requests.exceptions.Timeout:
            print("⏰ Request timed out")
        except Exception as e:
            print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_api()
