variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "domain_aliases" {
  description = "Domain aliases for CloudFront (e.g., ['rettai.com', 'www.rettai.com'])"
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN (must be in us-east-1)"
  type        = string
}

variable "web_origin_domain" {
  description = "Origin domain for web app (Amplify default domain)"
  type        = string
}

variable "admin_origin_domain" {
  description = "Origin domain for admin app (Amplify default domain)"
  type        = string
}

variable "api_origin_domain" {
  description = "Origin domain for API Gateway"
  type        = string
}

variable "waf_web_acl_arn" {
  description = "WAF Web ACL ARN (optional)"
  type        = string
  default     = null
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100" # US, Canada, Europe
}

variable "api_cache_policy_id" {
  description = "Cache policy ID for API behavior (use managed policy 4135ea2d-6df8-44a3-9df3-4b5a84be39ad for no caching)"
  type        = string
  default     = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
}

variable "geo_restriction_type" {
  description = "Geo restriction type (none, whitelist, blacklist)"
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "Geo restriction locations (country codes)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
