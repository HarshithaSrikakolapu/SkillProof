import requests
import json

BASE_URL = 'http://127.0.0.1:5000'

def test_flow():
    print("1. Registering User...")
    email = "testuser@example.com"
    password = "password123"
    
    # Clean up if exists (optional, or just handle error)
    # Register
    res = requests.post(f'{BASE_URL}/auth/register', json={
        'email': email, 'password': password, 'role': 'Learner'
    })
    print(f"Register: {res.status_code} - {res.json()}")
    
    print("\n2. Logging In...")
    res = requests.post(f'{BASE_URL}/auth/login', json={
        'email': email, 'password': password
    })
    print(f"Login: {res.status_code}")
    if res.status_code != 200:
        return
    
    token = res.json()['access_token']
    headers = {'Authorization': f'Bearer {token}'}
    
    print("\n3. Fetching Skills...")
    res = requests.get(f'{BASE_URL}/skills/', headers=headers)
    print(f"Skills: {res.status_code} - {res.text}")
    if res.status_code != 200:
        return

    skill_id = res.json()[0]['id']
    
    print(f"\n4. Fetching Assessments for Skill ID {skill_id}...")
    res = requests.get(f'{BASE_URL}/skills/{skill_id}/assessments', headers=headers)
    print(f"Assessments: {res.status_code} - {len(res.json())} items found")
    
    if len(res.json()) > 0:
        assessment_id = res.json()[0]['id']
        print(f"\n5. Starting Assessment {assessment_id}...")
        res = requests.post(f'{BASE_URL}/skills/assessments/{assessment_id}/start', headers=headers)
        print(f"Start: {res.status_code} - {res.json()}")
        
        ua_id = res.json()['id']
        
        print(f"\n6. Submitting Assessment {ua_id}...")
        # Simulating FormData with JSON string in 'data' field
        data_payload = {
            'user_assessment_id': ua_id,
            'responses': {'text_answer': 'A list is a sequence of elements in brackets.'} 
        }
        files = {
            'data': (None, json.dumps(data_payload), 'application/json'),
            'evidence_1': ('test.txt', b'This is evidence content', 'text/plain')
        }
        res = requests.post(f'{BASE_URL}/skills/assessments/submit', headers=headers, files=files)
        print(f"Submit: {res.status_code} - {res.text}")
        
    print("\n7. Verifying Credentials...")
    res = requests.get(f'{BASE_URL}/credentials/me', headers=headers)
    print(f"Credentials Me: {res.status_code} - {res.json()}")
    if len(res.json()) > 0:
        cred = res.json()[0]
        cred_id = cred['id']
        print(f"       Signature: {cred.get('signature', 'MISSING')[:10]}...") 
        print(f"\n8. Public Verification {cred_id}...")
        res = requests.get(f'{BASE_URL}/credentials/{cred_id}')
        print(f"Verify: {res.status_code} - {res.json()}")

    print("\n9. Employer Flow: Register & Login...")
    emp_payload = {'email': 'employer@test.com', 'password': 'password123', 'role': 'Employer'}
    requests.post(f'{BASE_URL}/auth/register', json=emp_payload) # Might fail if exists, we check login
    
    res = requests.post(f'{BASE_URL}/auth/login', json={'email': 'employer@test.com', 'password': 'password123'})
    if res.status_code == 200:
        emp_token = res.json()['access_token']
        emp_headers = {'Authorization': f'Bearer {emp_token}'}
        
        print("10. Employer Search...")
        res = requests.get(f'{BASE_URL}/employer/candidates?q=testuser', headers=emp_headers)
        print(f"Search: {res.status_code} - Found {len(res.json())}")
        
        if len(res.json()) > 0:
            target_id = res.json()[0]['id']
            print(f"11. View Candidate Profile {target_id}...")
            res = requests.get(f'{BASE_URL}/employer/candidates/{target_id}', headers=emp_headers)
            print(f"Profile: {res.status_code} - Credentials: {len(res.json()['credentials'])}")

    print("\n12. Analytics Check...")
    # Use Learner token
    res = requests.get(f'{BASE_URL}/analytics/user/me', headers=headers)
    if res.status_code == 404:
        print("Analytics Endpoint not found (Server might need restart)")
    else:
        print(f"User Progress: {res.status_code} - {res.json()}")

    res = requests.get(f'{BASE_URL}/analytics/skills')
    print(f"Global Stats: {res.status_code} - {res.text}")



if __name__ == "__main__":
    try:
        test_flow()
    except Exception as e:
        print(f"Test failed: {e}")
