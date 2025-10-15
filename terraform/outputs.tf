# Route53 Outputs
output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = local.route53_zone_id
}

output "route53_nameservers" {
  description = "Route53 nameservers for domain configuration"
  value       = var.create_route53_zone ? module.route53[0].name_servers : data.aws_route53_zone.existing[0].name_servers
}

# Amplify Outputs
output "amplify_app_id" {
  description = "Amplify app ID"
  value       = module.amplify.app_id
}

output "amplify_default_domain" {
  description = "Amplify default domain"
  value       = module.amplify.default_domain
}

output "amplify_branch_url" {
  description = "Amplify branch URL"
  value       = module.amplify.branch_url
}

output "amplify_custom_domain_url" {
  description = "Custom domain URL"
  value       = module.amplify.custom_domain_url
}

# WAF Outputs
output "waf_web_acl_id" {
  description = "WAF Web ACL ID"
  value       = var.enable_waf ? module.waf[0].web_acl_id : null
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = var.enable_waf ? module.waf[0].web_acl_arn : null
}
