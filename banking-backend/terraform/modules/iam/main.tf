resource "aws_iam_policy" "flask_cognito_policy" {
    name = "flask-cognito-policy"

    
    policy = jsondecode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow", 
                Action = [
                    "cognito-identity:GetCredentialsForIdentity"
                ],
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role" "flask_cognito_role" {
  name = "flask-cognito-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "flask_policy_attachment" {
  role       = aws_iam_role.flask_cognito_role.name
  policy_arn = aws_iam_policy.flask_cognito_policy.arn
}
