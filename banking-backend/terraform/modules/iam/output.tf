output "flask_cognito_role_arn" {
  value = aws_iam_role.flask_cognito_role.arn
  description = "The ARN of the IAM Role for Cognito authenticated users."
}
