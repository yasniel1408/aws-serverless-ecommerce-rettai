# Web Rettai - Main Site
# Uses generic Amplify module

module "web_rettai_amplify" {
  source = "../../modules/amplify"

  app_name            = "${var.project_name}-web-${var.environment}"
  repository          = var.github_repository
  branch_name         = var.github_branch
  github_access_token = var.github_token
  project_name        = var.project_name
  environment         = var.environment

  # Custom domain
  enable_domain    = true
  domain_name      = var.domain_name
  subdomain_prefix = "" # Root domain

  # Build spec específico para web-rettai con SSR
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - cd frontends/web-rettai
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: frontends/web-rettai/.next
        files:
          - '**/*'
      cache:
        paths:
          - frontends/web-rettai/node_modules/**/*
          - frontends/web-rettai/.next/cache/**/*
  EOT

  # Framework for SSR
  framework = "Next.js - SSR"
  platform  = "WEB_COMPUTE"

  # Custom rules for Next.js SSR (no son necesarias las SPA rules)
  custom_rules = []

  environment_variables = merge(
    var.amplify_environment_variables,
    {
      APP_NAME = "web-rettai"
    }
  )
}
