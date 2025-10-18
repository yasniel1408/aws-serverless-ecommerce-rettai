variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "api_gateway_id" {
  description = "API Gateway ID to attach Lambda routes"
  type        = string
}

variable "api_gateway_execution_arn" {
  description = "API Gateway execution ARN for Lambda permissions"
  type        = string
}

variable "identity_api_url" {
  description = "Identity API URL for authentication"
  type        = string
}

variable "cors_origin" {
  description = "CORS origin for API"
  type        = string
  default     = "*"
}

# VPC Configuration
variable "vpc_id" {
  description = "VPC ID for Lambda and RDS"
  type        = string
}

variable "vpc_private_subnet_ids" {
  description = "Private subnet IDs for Lambda and RDS"
  type        = list(string)
}

# Database Configuration
variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_min_capacity" {
  description = "Minimum Aurora capacity units (0.5 ACU)"
  type        = number
  default     = 0.5
}

variable "db_max_capacity" {
  description = "Maximum Aurora capacity units"
  type        = number
  default     = 2
}

variable "db_backup_retention_period" {
  description = "Database backup retention period in days"
  type        = number
  default     = 7
}

variable "db_skip_final_snapshot" {
  description = "Skip final database snapshot on deletion"
  type        = bool
  default     = false
}

# Logging
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
