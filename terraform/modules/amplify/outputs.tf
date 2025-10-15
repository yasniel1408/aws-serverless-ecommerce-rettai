output "app_id" {
  description = "Amplify app ID"
  value       = aws_amplify_app.main.id
}

output "app_arn" {
  description = "Amplify app ARN"
  value       = aws_amplify_app.main.arn
}

output "default_domain" {
  description = "Default Amplify domain"
  value       = aws_amplify_app.main.default_domain
}

output "branch_name" {
  description = "Branch name"
  value       = aws_amplify_branch.main.branch_name
}

output "branch_url" {
  description = "Branch URL"
  value       = "https://${var.branch_name}.${aws_amplify_app.main.default_domain}"
}

output "custom_domain_url" {
  description = "Custom domain URL"
  value       = "https://${var.domain_name}"
}

output "domain_association_status" {
  description = "Domain association status"
  value       = aws_amplify_domain_association.main.certificate_verification_dns_record
}
