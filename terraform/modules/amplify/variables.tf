variable "app_name" {
  description = "Amplify app name"
  type        = string
}

variable "repository" {
  description = "GitHub repository URL (e.g., https://github.com/user/repo)"
  type        = string
}

variable "branch_name" {
  description = "GitHub branch to deploy"
  type        = string
  default     = "main"
}

variable "github_access_token" {
  description = "GitHub personal access token for repository access"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "domain_name" {
  description = "Custom domain name (optional)"
  type        = string
  default     = ""
}

variable "enable_domain" {
  description = "Enable custom domain association"
  type        = bool
  default     = false
}

variable "enable_auto_branch_creation" {
  description = "Enable automatic branch creation"
  type        = bool
  default     = false
}

variable "enable_auto_build" {
  description = "Enable auto build on push"
  type        = bool
  default     = true
}

variable "enable_branch_auto_deletion" {
  description = "Enable automatic branch deletion"
  type        = bool
  default     = true
}

variable "framework" {
  description = "Framework for build (e.g., Next.js - SSR, Next.js - SSG)"
  type        = string
  default     = "Next.js - SSR"
}

variable "platform" {
  description = "Amplify platform type (WEB for SSG, WEB_COMPUTE for SSR)"
  type        = string
  default     = "WEB_COMPUTE"
}

variable "build_spec" {
  description = "Build spec (YAML format)"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for build"
  type        = map(string)
  default     = {}
}

variable "custom_rules" {
  description = "Custom routing rules"
  type = list(object({
    source = string
    target = string
    status = string
  }))
  default = []
}

variable "subdomain_prefix" {
  description = "Subdomain prefix for custom domain (e.g., 'www', 'admin')"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
