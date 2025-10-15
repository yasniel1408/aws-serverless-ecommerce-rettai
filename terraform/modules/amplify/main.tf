# Amplify App
resource "aws_amplify_app" "main" {
  name       = var.app_name
  repository = var.repository

  # GitHub access token
  access_token = var.github_access_token

  # Build settings
  build_spec = var.build_spec != "" ? var.build_spec : <<-EOT
    version: 1
    applications:
      - appRoot: frontends/web-rettai
        frontend:
          phases:
            preBuild:
              commands:
                - npm ci
            build:
              commands:
                - npm run build
          artifacts:
            baseDirectory: out
            files:
              - '**/*'
          cache:
            paths:
              - node_modules/**/*
      - appRoot: frontends/web-rettai-admin
        frontend:
          phases:
            preBuild:
              commands:
                - npm ci
            build:
              commands:
                - npm run build
          artifacts:
            baseDirectory: out
            files:
              - '**/*'
          cache:
            paths:
              - node_modules/**/*
  EOT

  # Platform
  platform = "WEB_COMPUTE"

  # Auto branch creation
  enable_auto_branch_creation = var.enable_auto_branch_creation
  enable_branch_auto_build    = var.enable_auto_build
  enable_branch_auto_deletion = true

  # Environment variables
  dynamic "environment_variables" {
    for_each = var.environment_variables
    content {
      name  = environment_variables.key
      value = environment_variables.value
    }
  }

  # Custom rules for routing
  custom_rule {
    source = "/admin"
    target = "/admin/index.html"
    status = "200"
  }

  custom_rule {
    source = "/admin/*"
    target = "/admin/index.html"
    status = "200"
  }

  custom_rule {
    source = "/<*>"
    target = "/index.html"
    status = "404-200"
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

# Main branch
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

# Domain association
resource "aws_amplify_domain_association" "main" {
  app_id      = aws_amplify_app.main.id
  domain_name = var.domain_name

  # Root domain
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = ""
  }

  # WWW subdomain
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = "www"
  }

  wait_for_verification = false
}
