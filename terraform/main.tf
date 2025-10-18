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
  region  = var.aws_region
  profile = var.aws_profile
}

# Provider for WAF (must be us-east-1 for CloudFront)
provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = var.aws_profile
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

# System: Web Rettai (Main Site) - rettai.com
module "web_rettai" {
  source = "./systems/web-rettai"

  project_name                  = var.project_name
  environment                   = var.environment
  github_repository             = var.github_repository
  github_branch                 = var.github_branch
  github_token                  = var.github_token
  domain_name                   = var.domain_name
  amplify_environment_variables = var.amplify_environment_variables

  depends_on = [data.aws_route53_zone.existing, module.route53]
}

# System: Web Rettai Admin (Admin Panel) - admin.rettai.com
module "web_rettai_admin" {
  source = "./systems/web-rettai-admin"

  project_name                  = var.project_name
  environment                   = var.environment
  github_repository             = var.github_repository
  github_branch                 = var.github_branch
  github_token                  = var.github_token
  domain_name                   = var.domain_name
  amplify_environment_variables = var.amplify_environment_variables

  depends_on = [data.aws_route53_zone.existing, module.route53]
}

# System: API Gateway - api.rettai.com
module "api_gateway" {
  source = "./systems/api-gateway"

  project_name    = var.project_name
  environment     = var.environment
  domain_name     = var.domain_name
  route53_zone_id = local.route53_zone_id

  # CORS Configuration
  cors_allow_origins = var.api_cors_allow_origins
  cors_allow_methods = var.api_cors_allow_methods
  cors_allow_headers = var.api_cors_allow_headers
  cors_max_age       = var.api_cors_max_age

  # Throttling
  throttle_burst_limit = var.api_throttle_burst_limit
  throttle_rate_limit  = var.api_throttle_rate_limit

  # Logging
  log_retention_days = var.api_log_retention_days

  depends_on = [data.aws_route53_zone.existing, module.route53]
}

# System: Identity Lambda
module "identity_lambda" {
  source = "./systems/identity-lambda"

  project_name              = var.project_name
  environment               = var.environment
  aws_region                = var.aws_region
  api_gateway_id            = module.api_gateway.api_id
  api_gateway_execution_arn = module.api_gateway.api_execution_arn

  log_retention_days = var.lambda_log_retention_days

  depends_on = [module.api_gateway]
}

# VPC Module (for Lambda and RDS)
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones

  enable_nat_gateway = var.enable_nat_gateway
}

# System: Inventory Lambda (Admin-only inventory management)
module "inventory_lambda" {
  source = "./systems/inventory-lambda"

  project_name              = var.project_name
  environment               = var.environment
  aws_region                = var.aws_region
  api_gateway_id            = module.api_gateway.api_id
  api_gateway_execution_arn = module.api_gateway.api_execution_arn
  identity_api_url          = module.api_gateway.custom_domain_url

  # VPC Configuration
  vpc_id                 = module.vpc.vpc_id
  vpc_private_subnet_ids = module.vpc.private_subnet_ids

  # Database Configuration
  db_username                = var.inventory_db_username
  db_password                = var.inventory_db_password
  db_min_capacity            = var.inventory_db_min_capacity
  db_max_capacity            = var.inventory_db_max_capacity
  db_backup_retention_period = var.inventory_db_backup_retention
  db_skip_final_snapshot     = var.inventory_db_skip_final_snapshot

  # Logging
  log_retention_days = var.lambda_log_retention_days

  depends_on = [module.api_gateway, module.vpc]
}
