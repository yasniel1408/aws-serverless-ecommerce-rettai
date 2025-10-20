# Route53 Outputs
output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = local.route53_zone_id
}

output "route53_nameservers" {
  description = "Route53 nameservers for domain configuration"
  value       = var.create_route53_zone ? module.route53[0].name_servers : data.aws_route53_zone.existing[0].name_servers
}

# Web Rettai Outputs (Main Site) - Temporarily disabled
# output "web_rettai_app_id" {
#   description = "Web Rettai Amplify app ID"
#   value       = module.web_rettai.amplify_app_id
# }
#
# output "web_rettai_url" {
#   description = "Web Rettai URL"
#   value       = module.web_rettai.custom_domain_url
# }
#
# # Web Rettai Admin Outputs (Admin Panel) - Temporarily disabled
# output "web_rettai_admin_app_id" {
#   description = "Web Rettai Admin Amplify app ID"
#   value       = module.web_rettai_admin.amplify_app_id
# }
#
# output "web_rettai_admin_url" {
#   description = "Web Rettai Admin URL"
#   value       = module.web_rettai_admin.custom_domain_url
# }

# WAF Outputs
output "waf_web_acl_id" {
  description = "WAF Web ACL ID"
  value       = var.enable_waf ? module.waf[0].web_acl_id : null
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = var.enable_waf ? module.waf[0].web_acl_arn : null
}

# API Gateway Outputs
output "api_gateway_id" {
  description = "API Gateway ID"
  value       = module.api_gateway.api_id
}

output "api_gateway_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_endpoint
}

output "api_gateway_custom_domain_url" {
  description = "API Gateway custom domain URL"
  value       = module.api_gateway.custom_domain_url
}

# Identity Lambda Outputs
output "identity_lambda_function_name" {
  description = "Identity Lambda function name"
  value       = module.identity_lambda.lambda_function_name
}

output "identity_cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.identity_lambda.cognito_user_pool_id
}

output "identity_cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = module.identity_lambda.cognito_user_pool_client_id
}

output "identity_dynamodb_table_name" {
  description = "Identity DynamoDB table name"
  value       = module.identity_lambda.dynamodb_table_name
}

output "identity_auth_endpoints" {
  description = "Identity authentication endpoints"
  value       = module.identity_lambda.auth_endpoints
}

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "vpc_private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# Inventory Lambda Outputs
output "inventory_lambda_function_name" {
  description = "Inventory Lambda function name"
  value       = module.inventory_lambda.lambda_function_name
}

output "inventory_rds_endpoint" {
  description = "Inventory RDS cluster endpoint"
  value       = module.inventory_lambda.rds_cluster_endpoint
  sensitive   = true
}

output "inventory_rds_secret_arn" {
  description = "Inventory RDS credentials secret ARN"
  value       = module.inventory_lambda.rds_secret_arn
}

output "inventory_api_endpoints" {
  description = "Inventory API endpoints"
  value       = module.inventory_lambda.api_endpoints
}
