output "api_id" {
  description = "API Gateway ID"
  value       = module.api_gateway.api_id
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_endpoint
}

output "api_arn" {
  description = "API Gateway ARN"
  value       = module.api_gateway.api_arn
}

output "stage_invoke_url" {
  description = "API Gateway stage invoke URL"
  value       = module.api_gateway.stage_invoke_url
}

output "custom_domain_url" {
  description = "Custom domain URL"
  value       = "https://api.${var.domain_name}"
}

output "api_execution_arn" {
  description = "API Gateway execution ARN (for Lambda permissions)"
  value       = "${module.api_gateway.api_arn}/*"
}
