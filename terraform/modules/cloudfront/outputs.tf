output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.main.arn
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "distribution_hosted_zone_id" {
  description = "CloudFront distribution hosted zone ID (for Route53)"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}

output "api_secret_parameter_name" {
  description = "SSM Parameter name for API secret"
  value       = aws_ssm_parameter.api_secret.name
}

output "api_secret_value" {
  description = "API secret value (sensitive)"
  value       = random_password.api_secret.result
  sensitive   = true
}
