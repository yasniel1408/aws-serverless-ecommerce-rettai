# Route53 Outputs
output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = local.route53_zone_id
}

output "route53_nameservers" {
  description = "Route53 nameservers for domain configuration"
  value       = var.create_route53_zone ? module.route53[0].name_servers : data.aws_route53_zone.existing[0].name_servers
}

# Web Rettai Outputs (Main Site)
output "web_rettai_app_id" {
  description = "Web Rettai Amplify app ID"
  value       = module.web_rettai.amplify_app_id
}

output "web_rettai_url" {
  description = "Web Rettai URL"
  value       = module.web_rettai.custom_domain_url
}

# Web Rettai Admin Outputs (Admin Panel)
output "web_rettai_admin_app_id" {
  description = "Web Rettai Admin Amplify app ID"
  value       = module.web_rettai_admin.amplify_app_id
}

output "web_rettai_admin_url" {
  description = "Web Rettai Admin URL"
  value       = module.web_rettai_admin.custom_domain_url
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
