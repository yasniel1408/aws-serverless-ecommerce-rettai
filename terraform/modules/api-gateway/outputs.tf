output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.main.id
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "api_arn" {
  description = "API Gateway ARN"
  value       = aws_apigatewayv2_api.main.arn
}

output "stage_id" {
  description = "API Gateway stage ID"
  value       = aws_apigatewayv2_stage.main.id
}

output "stage_invoke_url" {
  description = "API Gateway stage invoke URL"
  value       = aws_apigatewayv2_stage.main.invoke_url
}

output "custom_domain_name" {
  description = "Custom domain name"
  value       = aws_apigatewayv2_domain_name.main.domain_name
}

output "custom_domain_target" {
  description = "Custom domain target domain name (for Route53)"
  value       = aws_apigatewayv2_domain_name.main.domain_name_configuration[0].target_domain_name
}

output "custom_domain_hosted_zone_id" {
  description = "Custom domain hosted zone ID (for Route53)"
  value       = aws_apigatewayv2_domain_name.main.domain_name_configuration[0].hosted_zone_id
}
