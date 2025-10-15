terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Provider for WAF (must be us-east-1 for CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Route53 Module (solo si se necesita crear nueva zona)
module "route53" {
  count  = var.create_route53_zone ? 1 : 0
  source = "./modules/route53"

  domain_name  = var.domain_name
  project_name = var.project_name
  environment  = var.environment
}

# Data source para hosted zone existente
data "aws_route53_zone" "existing" {
  count   = var.create_route53_zone ? 0 : 1
  zone_id = var.existing_route53_zone_id
}

# Local para determinar qué zone_id usar
locals {
  route53_zone_id = var.create_route53_zone ? module.route53[0].zone_id : data.aws_route53_zone.existing[0].zone_id
}

# WAF Module (optional - para proteger Amplify con CloudFront)
module "waf" {
  count  = var.enable_waf ? 1 : 0
  source = "./modules/waf"
  
  providers = {
    aws = aws.us_east_1
  }

  project_name            = var.project_name
  environment             = var.environment
  enable_core_rule_set    = var.enable_waf_core_rules
  enable_known_bad_inputs = var.enable_waf_bad_inputs
  enable_rate_limiting    = var.enable_waf_rate_limit
  rate_limit              = var.waf_rate_limit
  enable_geo_blocking     = var.enable_waf_geo_blocking
  blocked_countries       = var.waf_blocked_countries
}

# Amplify Module - Deploy frontends from GitHub
module "amplify" {
  source = "./modules/amplify"

  app_name            = "${var.project_name}-${var.environment}"
  repository          = var.github_repository
  branch_name         = var.github_branch
  github_access_token = var.github_token
  domain_name         = var.domain_name
  project_name        = var.project_name
  environment         = var.environment

  environment_variables = var.amplify_environment_variables

  depends_on = [data.aws_route53_zone.existing, module.route53]
}
