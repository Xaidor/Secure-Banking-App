module "iam" {
    source = "./modules/iam"
}

module "secure_cognito" {
  source = "./modules/cognito"
  authenticated_role_arn = module.iam.flask_cognito_role_arn
}
