from flask import Flask, request, jsonify
import boto3
import jwt
from functools import wraps

app = Flask(__name__)

# Cognito configuration
COGNITO_POOL_ID = '<your_user_pool_id>'
COGNITO_CLIENT_ID = '<your_user_pool_client_id>'
COGNITO_REGION = 'us-east-1'

# Initialize AWS Cognito client
cognito_client = boto3.client('cognito-idp', region_name=COGNITO_REGION)

# JWT token verification function
def check_token(token):
    try:
        # Verify the token with Cognito's public keys (from well-known URL)
        response = cognito_client.get_jwk_keys()
        public_key = response['keys'][0]  # Choose the correct key for your pool
        payload = jwt.decode(token, public_key, algorithms=['RS256'], audience=COGNITO_CLIENT_ID)
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None

# Token required decorator
def token_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            token = request.headers['Authorization']
        
        if not token:
            return jsonify({'message': 'Token is missing!'}), 403
        
        payload = check_token(token)
        if not payload:
            return jsonify({'message': 'Token is invalid or expired!'}), 403
        
        return f(payload, *args, **kwargs)
    
    return decorated_function

# Secure endpoint example
@app.route('/account', methods=['GET'])
@token_required
def account_info(user, **kwargs):
    # Logic to interact with PostgreSQL database and fetch user account info
    return jsonify({'message': 'Account data', 'user': user})

if __name__ == '__main__':
    app.run(debug=True)
