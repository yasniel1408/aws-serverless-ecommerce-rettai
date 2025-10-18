# API Gateway System
# This system sets up the main API Gateway for the application

# ACM Certificate for api.domain.com
resource "aws_acm_certificate" "api" {
  domain_name       = "api.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      Name        = "${var.project_name}-api-${var.environment}-cert"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# API Gateway Module
module "api_gateway" {
  source = "../../modules/api-gateway"

  project_name        = var.project_name
  environment         = var.environment
  custom_domain_name  = "api.${var.domain_name}"
  acm_certificate_arn = aws_acm_certificate.api.arn

  # CORS Configuration
  cors_allow_origins = var.cors_allow_origins
  cors_allow_methods = var.cors_allow_methods
  cors_allow_headers = var.cors_allow_headers
  cors_max_age       = var.cors_max_age

  # Throttling
  throttle_burst_limit = var.throttle_burst_limit
  throttle_rate_limit  = var.throttle_rate_limit

  # Logging
  log_retention_days = var.log_retention_days

  tags = var.tags
}

# Route53 Record for API Gateway custom domain
resource "aws_route53_record" "api" {
  zone_id = var.route53_zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = module.api_gateway.custom_domain_target
    zone_id                = module.api_gateway.custom_domain_hosted_zone_id
    evaluate_target_health = false
  }
}

# ACM Certificate Validation Records
resource "aws_route53_record" "api_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

# ACM Certificate Validation
resource "aws_acm_certificate_validation" "api" {
  certificate_arn         = aws_acm_certificate.api.arn
  validation_record_fqdns = [for record in aws_route53_record.api_cert_validation : record.fqdn]
}
