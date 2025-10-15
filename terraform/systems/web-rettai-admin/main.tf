# Web Rettai Admin - Admin Panel
# Uses generic Amplify module

module "web_rettai_admin_amplify" {
  source = "../../modules/amplify"

  app_name            = "${var.project_name}-admin-${var.environment}"
  repository          = var.github_repository
  branch_name         = var.github_branch
  github_access_token = var.github_token
  project_name        = var.project_name
  environment         = var.environment

  # Custom domain con subdomain
  enable_domain    = true
  domain_name      = var.domain_name
  subdomain_prefix = "admin" # admin.rettai.com

  # Build spec específico para web-rettai-admin con SSR
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - cd frontends/web-rettai-admin
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: frontends/web-rettai-admin/.next
        files:
          - '**/*'
      cache:
        paths:
          - frontends/web-rettai-admin/node_modules/**/*
          - frontends/web-rettai-admin/.next/cache/**/*
  EOT

  # Framework for SSR
  framework = "Next.js - SSR"
  platform  = "WEB_COMPUTE"

  # Custom rules for Next.js SSR (no son necesarias las SPA rules)
  custom_rules = []

  environment_variables = merge(
    var.amplify_environment_variables,
    {
      APP_NAME = "web-rettai-admin"
    }
  )
}
