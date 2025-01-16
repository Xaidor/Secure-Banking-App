resource "aws_cognito_user_pool" "user_pool" {
  name = "mypool"
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "my-user-pool-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}