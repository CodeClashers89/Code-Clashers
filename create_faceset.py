import requests
import json
import time

api_key = 'KtGZPcOdHRJgE8_GtcIwR8EuTTr5sS2S'
api_secret = 'q_j45mmmE6rqBEiGgzCHvaf9SjSvoltQ'
api_url = 'https://api-us.faceplusplus.com/facepp/v3/faceset/create'

# Use a timestamp-based outer_id to avoid "already exists" errors if we run multiple times
outer_id = f'ingenium_users_{int(time.time())}'

data = {
    'api_key': api_key,
    'api_secret': api_secret,
    'display_name': 'IngeniumUsers',
    'outer_id': outer_id
}

try:
    print(f"Sending request to {api_url} with outer_id={outer_id}...")
    response = requests.post(api_url, data=data)
    
    try:
        result = response.json()
        print("\n--- API RESPONSE ---")
        print(json.dumps(result, indent=2))
        print("--------------------")
        
        if 'faceset_token' in result:
            print(f"\nSUCCESS! Your faceset_token is: {result['faceset_token']}")
        else:
            print("\nWARNING: faceset_token not found in response.")
            
    except json.JSONDecodeError:
        print("Failed to decode JSON response:")
        print(response.text)

except Exception as e:
    print(f"Error: {e}")
