variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "enable_core_rule_set" {
  description = "Enable AWS Managed Rules Core Rule Set"
  type        = bool
  default     = true
}

variable "enable_known_bad_inputs" {
  description = "Enable AWS Managed Rules Known Bad Inputs"
  type        = bool
  default     = true
}

variable "enable_rate_limiting" {
  description = "Enable rate limiting rule"
  type        = bool
  default     = true
}

variable "rate_limit" {
  description = "Rate limit threshold per IP"
  type        = number
  default     = 2000
}

variable "enable_geo_blocking" {
  description = "Enable geo blocking rule"
  type        = bool
  default     = false
}

variable "blocked_countries" {
  description = "List of country codes to block"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
