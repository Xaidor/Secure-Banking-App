from flask import Flask, request, jsonify
import boto3
import jwt
from functools import wraps

app = Flask(__name__)

# Cognito JWT validation
def check_token(token):
    # Cognito public keys URL
    url = "https://cognito-idp.us-east-1.amazonaws.com/<your_user_pool_id>/.well-known/jwks.json"
    response = requests.get(url)
    jwks = response.json()
    
    # Validate token against public keys
    try:
        payload = jwt.decode(token, jwks, algorithms=["RS256"], audience="<your_client_id>")
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None

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

@app.route('/account', methods=['GET'])
@token_required
def account_info(user, **kwargs):
    # Example: fetch user account info from PostgreSQL based on Cognito user ID
    # Add your PostgreSQL query logic here
    return jsonify({'message': 'Account data', 'user': user})

if __name__ == '__main__':
    app.run(debug=True)
