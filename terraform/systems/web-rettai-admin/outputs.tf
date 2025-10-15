output "amplify_app_id" {
  description = "Amplify app ID"
  value       = module.web_rettai_admin_amplify.app_id
}

output "amplify_default_domain" {
  description = "Amplify default domain"
  value       = module.web_rettai_admin_amplify.default_domain
}

output "amplify_branch_url" {
  description = "Amplify branch URL"
  value       = module.web_rettai_admin_amplify.branch_url
}

output "custom_domain_url" {
  description = "Custom domain URL"
  value       = "https://admin.${var.domain_name}"
}
