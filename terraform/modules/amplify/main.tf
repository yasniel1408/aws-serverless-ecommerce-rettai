# Amplify App - Generic for single app
resource "aws_amplify_app" "main" {
  name       = var.app_name
  repository = var.repository

  # GitHub access token
  access_token = var.github_access_token

  # Build settings
  build_spec = var.build_spec

  # Platform
  platform = var.platform

  # Auto branch creation
  enable_auto_branch_creation = var.enable_auto_branch_creation
  enable_branch_auto_build    = var.enable_auto_build
  enable_branch_auto_deletion = var.enable_branch_auto_deletion

  # Environment variables
  environment_variables = var.environment_variables

  # Custom rules (optional)
  dynamic "custom_rule" {
    for_each = var.custom_rules
    content {
      source = custom_rule.value.source
      target = custom_rule.value.target
      status = custom_rule.value.status
    }
  }

  tags = merge(
    {
      Name        = var.app_name
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}
# Main branch deployment
resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.main.id
  branch_name = var.branch_name

  enable_auto_build = var.enable_auto_build

  framework = var.framework

  stage = var.environment == "prod" ? "PRODUCTION" : var.environment == "staging" ? "BETA" : "DEVELOPMENT"

  tags = merge(
    {
      Name        = "${var.app_name}-${var.branch_name}"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}
# Domain association for custom domain (optional)
resource "aws_amplify_domain_association" "main" {
  count = var.enable_domain ? 1 : 0

  app_id      = aws_amplify_app.main.id
  domain_name = var.domain_name

  # Subdomain configuration
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = var.subdomain_prefix
  }

  wait_for_verification = false
}
