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

# API Gateway Configuration
variable "api_cors_allow_origins" {
  description = "CORS allowed origins for API Gateway"
  type        = list(string)
  default     = ["*"]
}

variable "api_cors_allow_methods" {
  description = "CORS allowed methods for API Gateway"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"]
}

variable "api_cors_allow_headers" {
  description = "CORS allowed headers for API Gateway"
  type        = list(string)
  default     = ["*"]
}

variable "api_cors_max_age" {
  description = "CORS max age in seconds for API Gateway"
  type        = number
  default     = 300
}

variable "api_throttle_burst_limit" {
  description = "API Gateway throttle burst limit"
  type        = number
  default     = 5000
}

variable "api_throttle_rate_limit" {
  description = "API Gateway throttle rate limit (requests per second)"
  type        = number
  default     = 10000
}

variable "api_log_retention_days" {
  description = "API Gateway CloudWatch log retention in days"
  type        = number
  default     = 7
}

# Lambda Configuration
variable "lambda_log_retention_days" {
  description = "Lambda CloudWatch log retention in days"
  type        = number
  default     = 7
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for VPC subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT gateway for private subnets"
  type        = bool
  default     = true
}

# Inventory Database Configuration
variable "inventory_db_username" {
  description = "Inventory database master username"
  type        = string
  default     = "inventory_admin"
  sensitive   = true
}

variable "inventory_db_password" {
  description = "Inventory database master password"
  type        = string
  sensitive   = true
}

variable "inventory_db_min_capacity" {
  description = "Minimum Aurora capacity units for inventory DB"
  type        = number
  default     = 0.5
}

variable "inventory_db_max_capacity" {
  description = "Maximum Aurora capacity units for inventory DB"
  type        = number
  default     = 2
}

variable "inventory_db_backup_retention" {
  description = "Backup retention period in days for inventory DB"
  type        = number
  default     = 7
}

variable "inventory_db_skip_final_snapshot" {
  description = "Skip final snapshot on deletion for inventory DB"
  type        = bool
  default     = false
}
