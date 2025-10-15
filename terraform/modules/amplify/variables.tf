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
  description = "Custom domain name"
  type        = string
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

variable "framework" {
  description = "Framework for build (e.g., Next.js SSR, Next.js SSG)"
  type        = string
  default     = "Next.js - SSG"
}

variable "build_spec" {
  description = "Custom build spec (YAML format)"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Environment variables for build"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
