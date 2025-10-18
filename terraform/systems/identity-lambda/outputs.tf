output "lambda_function_name" {
  description = "Identity Lambda function name"
  value       = module.identity_lambda.function_name
}

output "lambda_function_arn" {
  description = "Identity Lambda function ARN"
  value       = module.identity_lambda.function_arn
}

output "lambda_invoke_arn" {
  description = "Identity Lambda invoke ARN"
  value       = module.identity_lambda.invoke_arn
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.identity_cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = module.identity_cognito.client_id
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for identity"
  value       = module.identity_dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN for identity"
  value       = module.identity_dynamodb.table_arn
}

output "policy_store_id" {
  description = "Verified Permissions policy store ID"
  value       = module.identity_verified_permissions.policy_store_id
}

output "auth_endpoints" {
  description = "Authentication endpoints"
  value = {
    login     = "POST /auth/login"
    google    = "POST /auth/google"
    refresh   = "POST /auth/refresh"
    me        = "GET /auth/me"
    authorize = "POST /auth/authorize"
  }
}
