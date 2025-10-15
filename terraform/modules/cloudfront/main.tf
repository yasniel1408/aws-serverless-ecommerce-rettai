# CloudFront Distribution with multiple origins
# Routes traffic to: Web App, Admin App, and API Gateway

# Generate random secret for API Gateway header
resource "random_password" "api_secret" {
  length  = 32
  special = true
}

# CloudFront Origin Request Policy for custom headers
resource "aws_cloudfront_origin_request_policy" "api_gateway" {
  name    = "${var.project_name}-${var.environment}-api-gateway-policy"
  comment = "Policy for API Gateway with custom header"

  cookies_config {
    cookie_behavior = "all"
  }

  headers_config {
    header_behavior = "allViewerAndWhitelistCloudFront"
    headers {
      items = ["CloudFront-Viewer-Country", "X-CloudFront-Secret"]
    }
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.project_name} ${var.environment} Distribution"
  default_root_object = "index.html"
  price_class         = var.price_class
  aliases             = var.domain_aliases
  web_acl_id          = var.waf_web_acl_arn

  # Origin 1: Web Rettai (Amplify)
  origin {
    domain_name = var.web_origin_domain
    origin_id   = "web-rettai"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Origin 2: Web Rettai Admin (Amplify)
  origin {
    domain_name = var.admin_origin_domain
    origin_id   = "web-rettai-admin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Origin 3: API Gateway
  origin {
    domain_name = var.api_origin_domain
    origin_id   = "api-gateway"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "X-CloudFront-Secret"
      value = random_password.api_secret.result
    }
  }

  # Default behavior: Web Rettai
  default_cache_behavior {
    target_origin_id       = "web-rettai"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = true
      headers      = ["Host", "CloudFront-Viewer-Country"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 300
    max_ttl     = 86400
  }

  # Behavior: Admin App (/admin/*)
  ordered_cache_behavior {
    path_pattern           = "/admin/*"
    target_origin_id       = "web-rettai-admin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = true
      headers      = ["Host", "CloudFront-Viewer-Country"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 300
    max_ttl     = 86400
  }

  # Behavior: API Gateway (/api/*)
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "api-gateway"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    origin_request_policy_id = aws_cloudfront_origin_request_policy.api_gateway.id
    cache_policy_id          = var.api_cache_policy_id # Managed policy for API Gateway

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  # SSL Certificate
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Custom error responses
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-cdn"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# Store API secret in SSM Parameter Store for API Gateway to validate
resource "aws_ssm_parameter" "api_secret" {
  name        = "/${var.project_name}/${var.environment}/cloudfront-api-secret"
  description = "Secret header value for CloudFront to API Gateway communication"
  type        = "SecureString"
  value       = random_password.api_secret.result

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-api-secret"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}
