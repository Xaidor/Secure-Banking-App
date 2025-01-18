resource "aws_iam_policy" "flask-policy" {
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
