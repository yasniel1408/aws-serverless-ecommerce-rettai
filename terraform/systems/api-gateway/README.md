# API Gateway System

This system provides a centralized HTTP API Gateway for all backend services.

## Features

- **Custom Domain**: api.rettai.com (or your configured domain)
- **CORS Configuration**: Configurable CORS for frontend integration
- **SSL/TLS**: Automatic HTTPS with ACM certificate
- **Throttling**: Rate limiting to protect backend services
- **Logging**: CloudWatch logs for all requests
- **Route53 Integration**: Automatic DNS configuration

## Resources Created

1. **AWS API Gateway HTTP API**: Main API Gateway
2. **ACM Certificate**: SSL/TLS certificate for api.domain.com
3. **Route53 Records**: DNS records for custom domain
4. **CloudWatch Log Group**: Request logging
5. **API Gateway Stage**: Default stage with auto-deploy

## Configuration

### Variables

- `project_name`: Project name
- `environment`: Environment (dev, staging, prod)
- `domain_name`: Base domain (e.g., rettai.com)
- `route53_zone_id`: Route53 hosted zone ID
- `cors_allow_origins`: CORS allowed origins (default: ["*"])
- `cors_allow_methods`: CORS allowed methods
- `cors_allow_headers`: CORS allowed headers
- `throttle_burst_limit`: Burst limit (default: 5000)
- `throttle_rate_limit`: Rate limit per second (default: 10000)
- `log_retention_days`: CloudWatch log retention (default: 7 days)

### Outputs

- `api_id`: API Gateway ID
- `api_endpoint`: API Gateway endpoint URL
- `stage_invoke_url`: Stage invoke URL
- `custom_domain_url`: Custom domain URL (https://api.domain.com)
- `api_execution_arn`: Execution ARN for Lambda permissions

## Usage

The API Gateway is automatically configured in the main Terraform configuration. Lambda functions can integrate by using the outputs:

```hcl
module "my_lambda" {
  source = "./path/to/lambda"
  
  api_gateway_id            = module.api_gateway.api_id
  api_gateway_execution_arn = module.api_gateway.api_execution_arn
}
```

## Endpoints

Endpoints are added by individual systems (like identity-lambda). The API Gateway serves as the central router for all backend services.

## Security

- HTTPS only (enforced by API Gateway)
- Rate limiting enabled
- CORS configured for frontend access
- CloudWatch logging for audit trail
