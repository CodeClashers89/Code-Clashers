import requests
import json
import time

api_key = 'KtGZPcOdHRJgE8_GtcIwR8EuTTr5sS2S'
api_secret = 'q_j45mmmE6rqBEiGgzCHvaf9SjSvoltQ'
api_url = 'https://api-us.faceplusplus.com/facepp/v3/faceset/create'

outer_id = f'ingenium_users_{int(time.time())}'

data = {
    'api_key': api_key,
    'api_secret': api_secret,
    'display_name': 'IngeniumUsers',
    'outer_id': outer_id
}

try:
    response = requests.post(api_url, data=data)
    result = response.json()
    
    with open('final_token.txt', 'w', encoding='utf-8') as f:
        if 'faceset_token' in result:
            f.write(result['faceset_token'])
        else:
            f.write("ERROR: " + json.dumps(result))
            
except Exception as e:
    with open('final_token.txt', 'w', encoding='utf-8') as f:
        f.write(str(e))
