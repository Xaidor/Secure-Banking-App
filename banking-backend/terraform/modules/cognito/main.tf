resource "aws_cognito_user_pool" "secure_banking_pool" {
  name = "mypool"

  password_policy {
    minimum_length = 8
    require_lowercase = true
    require_numbers = true
    require_symbols = false
    require_uppercase = true
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "flask-app-client"
  user_pool_id = aws_cognito_user_pool.secure_banking_pool.id
  generate_secret = false
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]       #ALLOW_USER_PASSWORD_AUTH: Enables username and password-based login. ALLOW_REFRESH_TOKEN_AUTH: Enables the use of refresh tokens to retrieve new access tokens after the initial one expires.
  allowed_oauth_flows = ["implicit"]                                                   #The app directly receives the access token in the callback URL without needing to exchange it for a code.
  allowed_oauth_scopes = ["openid", "email", "profile"]                                #openid: Required for OpenID Connect. Allows the app to fetch identity information like the user's ID. email: Grants access to the user's email address. profile: Grants access to general user information, such as their name or nickname.
  allowed_oauth_flows_user_pool_client = true                                          #Enables OAuth 2.0 capabilities for the app client, allowing it to handle user login via tokens
  callback_urls = ["http://localhost:5000/callback"]                                  #The redirect location after a successful user login.
}

resource "aws_cognito_identity_pool" "secure_banking_identity_pool" {
  identity_pool_name               = "secure-banking-identity-pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id    = aws_cognito_user_pool_client.user_pool_client.id
    provider_name = aws_cognito_user_pool.secure_banking_pool.endpoint
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "identity_pool_roles" {
  identity_pool_id = aws_cognito_identity_pool.secure_banking_identity_pool.id

  roles = {
    authenticated = var.authenticated_role_arn #Flask Cognito role arn from the iam module
  }
}