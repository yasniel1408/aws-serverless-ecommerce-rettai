# Identity Lambda System
# This system sets up the Identity Lambda function with all its dependencies

# DynamoDB Module for Identity
module "identity_dynamodb" {
  source = "../../modules/dynamodb"

  project_name = var.project_name
  environment  = var.environment
  table_name   = "identity-db"

  hash_key       = "userId"
  billing_mode   = "PAY_PER_REQUEST"
  stream_enabled = false

  attributes = [
    {
      name = "userId"
      type = "S"
    },
    {
      name = "email"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "email-index"
      hash_key        = "email"
      projection_type = "ALL"
    }
  ]

  tags = var.tags
}

# Cognito Module
module "identity_cognito" {
  source = "../../modules/cognito"

  project_name = var.project_name
  environment  = var.environment

  # Callback and logout URLs
  callback_urls = var.cognito_callback_urls
  logout_urls   = var.cognito_logout_urls

  # Google OAuth (optional)
  enable_google        = var.enable_google_oauth
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret

  # Token validity
  access_token_validity  = 60 # 60 minutes
  id_token_validity      = 60 # 60 minutes
  refresh_token_validity = 30 # 30 days

  # MFA
  mfa_configuration = "OPTIONAL"

  tags = var.tags
}

# Verified Permissions Module
module "identity_verified_permissions" {
  source = "../../modules/verified-permissions"

  project_name = var.project_name
  environment  = var.environment

  tags = var.tags
}

# Lambda deployment package
data "archive_file" "identity_lambda" {
  type        = "zip"
  source_dir  = "${path.root}/../lambdas/identity/src"
  output_path = "${path.root}/.terraform/tmp/identity-lambda.zip"
}

# Lambda Module for Identity
module "identity_lambda" {
  source = "../../modules/lambda"

  project_name    = var.project_name
  environment     = var.environment
  function_name   = "identity"
  lambda_zip_path = data.archive_file.identity_lambda.output_path
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 30
  memory_size     = 512

  environment_variables = {
    USER_POOL_ID    = module.identity_cognito.user_pool_id
    CLIENT_ID       = module.identity_cognito.client_id
    TABLE_NAME      = module.identity_dynamodb.table_name
    POLICY_STORE_ID = module.identity_verified_permissions.policy_store_id
    AWS_REGION      = var.aws_region
  }

  # Custom IAM policy for Lambda
  custom_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:AdminGetUser",
          "cognito-idp:AdminInitiateAuth",
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminSetUserPassword",
          "cognito-idp:AdminUpdateUserAttributes"
        ]
        Resource = module.identity_cognito.user_pool_arn
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          module.identity_dynamodb.table_arn,
          "${module.identity_dynamodb.table_arn}/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "verifiedpermissions:IsAuthorized",
          "verifiedpermissions:GetPolicy",
          "verifiedpermissions:ListPolicies"
        ]
        Resource = module.identity_verified_permissions.policy_store_arn
      }
    ]
  })

  # Connect to API Gateway
  api_gateway_id            = var.api_gateway_id
  api_gateway_execution_arn = var.api_gateway_execution_arn

  log_retention_days = var.log_retention_days

  tags = var.tags
}

# API Gateway Integration for Identity Lambda
resource "aws_apigatewayv2_integration" "identity" {
  api_id           = var.api_gateway_id
  integration_type = "AWS_PROXY"
  integration_uri  = module.identity_lambda.invoke_arn

  payload_format_version = "2.0"
}

# API Gateway Routes for Identity
resource "aws_apigatewayv2_route" "identity_login" {
  api_id    = var.api_gateway_id
  route_key = "POST /auth/login"
  target    = "integrations/${aws_apigatewayv2_integration.identity.id}"
}

resource "aws_apigatewayv2_route" "identity_google" {
  api_id    = var.api_gateway_id
  route_key = "POST /auth/google"
  target    = "integrations/${aws_apigatewayv2_integration.identity.id}"
}

resource "aws_apigatewayv2_route" "identity_refresh" {
  api_id    = var.api_gateway_id
  route_key = "POST /auth/refresh"
  target    = "integrations/${aws_apigatewayv2_integration.identity.id}"
}

resource "aws_apigatewayv2_route" "identity_me" {
  api_id    = var.api_gateway_id
  route_key = "GET /auth/me"
  target    = "integrations/${aws_apigatewayv2_integration.identity.id}"
}

resource "aws_apigatewayv2_route" "identity_authorize" {
  api_id    = var.api_gateway_id
  route_key = "POST /auth/authorize"
  target    = "integrations/${aws_apigatewayv2_integration.identity.id}"
}
