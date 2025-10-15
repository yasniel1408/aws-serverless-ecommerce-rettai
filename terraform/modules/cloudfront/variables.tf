variable "domain_name" {
  description = "Domain name for CloudFront distribution"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for DNS validation"
  type        = string
}

variable "origin_domain_name" {
  description = "Origin domain name (e.g., S3 bucket domain)"
  type        = string
}

variable "origin_id" {
  description = "Origin ID"
  type        = string
}

variable "origin_access_identity_path" {
  description = "CloudFront Origin Access Identity path"
  type        = string
}

variable "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  type        = string
}

variable "price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
}

variable "default_root_object" {
  description = "Default root object"
  type        = string
  default     = "index.html"
}

variable "enable_ipv6" {
  description = "Enable IPv6 for CloudFront distribution"
  type        = bool
  default     = true
}

variable "minimum_protocol_version" {
  description = "Minimum TLS protocol version"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "default_ttl" {
  description = "Default TTL for cached objects"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum TTL for cached objects"
  type        = number
  default     = 86400
}

variable "min_ttl" {
  description = "Minimum TTL for cached objects"
  type        = number
  default     = 0
}

variable "create_www_alias" {
  description = "Create www subdomain alias"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
