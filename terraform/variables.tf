# General Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "example.com"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "ecommerce"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Route53 Configuration
variable "create_route53_zone" {
  description = "Create new Route53 hosted zone or use existing one"
  type        = bool
  default     = false
}

variable "existing_route53_zone_id" {
  description = "Existing Route53 hosted zone ID (required if create_route53_zone is false)"
  type        = string
  default     = ""
}

# GitHub Configuration
variable "github_repository" {
  description = "GitHub repository URL (https://github.com/user/repo)"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to deploy"
  type        = string
  default     = "main"
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

# Amplify Configuration
variable "amplify_environment_variables" {
  description = "Environment variables for Amplify build"
  type        = map(string)
  default     = {}
}

# WAF Configuration
variable "enable_waf" {
  description = "Enable WAF for CloudFront protection"
  type        = bool
  default     = false
}

variable "enable_waf_core_rules" {
  description = "Enable AWS Managed Rules Core Rule Set"
  type        = bool
  default     = true
}

variable "enable_waf_bad_inputs" {
  description = "Enable AWS Managed Rules Known Bad Inputs"
  type        = bool
  default     = true
}

variable "enable_waf_rate_limit" {
  description = "Enable rate limiting rule"
  type        = bool
  default     = true
}

variable "waf_rate_limit" {
  description = "Rate limit threshold per IP"
  type        = number
  default     = 2000
}

variable "enable_waf_geo_blocking" {
  description = "Enable geo blocking rule"
  type        = bool
  default     = false
}

variable "waf_blocked_countries" {
  description = "List of country codes to block"
  type        = list(string)
  default     = []
}
