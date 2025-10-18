output "lambda_function_name" {
  description = "Inventory Lambda function name"
  value       = module.inventory_lambda.function_name
}

output "lambda_function_arn" {
  description = "Inventory Lambda function ARN"
  value       = module.inventory_lambda.function_arn
}

output "rds_cluster_endpoint" {
  description = "RDS cluster endpoint"
  value       = module.inventory_rds.cluster_endpoint
}

output "rds_cluster_id" {
  description = "RDS cluster ID"
  value       = module.inventory_rds.cluster_id
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.inventory_rds.database_name
}

output "rds_secret_arn" {
  description = "RDS credentials secret ARN"
  value       = module.inventory_rds.secret_arn
}

output "api_endpoints" {
  description = "Inventory API endpoints"
  value = {
    products   = "ANY /api/products"
    warehouses = "ANY /api/warehouses"
  }
}

output "security_group_id" {
  description = "Lambda security group ID"
  value       = aws_security_group.lambda.id
}
