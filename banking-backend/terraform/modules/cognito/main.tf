resource "aws_cognito_user_pool" "user_pool" {
  name = "mypool"

  dynamic "username_configuration" {
    for_each = local.username_configuration.value
    content {
      case_sensitive = lookup(username_configuration, "case_sensitive")
    }
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "my-user-pool-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}