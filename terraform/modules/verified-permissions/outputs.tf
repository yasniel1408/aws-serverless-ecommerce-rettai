output "policy_store_id" {
  description = "Verified Permissions Policy Store ID"
  value       = aws_verifiedpermissions_policy_store.main.id
}

output "policy_store_arn" {
  description = "Verified Permissions Policy Store ARN"
  value       = aws_verifiedpermissions_policy_store.main.arn
}
