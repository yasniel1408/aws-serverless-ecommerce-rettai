# Inventory Lambda System
# This system sets up the Inventory Lambda function with RDS Aurora Serverless PostgreSQL

# Lambda deployment package
data "archive_file" "inventory_lambda" {
  type        = "zip"
  source_dir  = "${path.root}/../lambdas/inventory/dist"
  output_path = "${path.root}/.terraform/tmp/inventory-lambda.zip"
}

# Lambda Module for Inventory
module "inventory_lambda" {
  source = "../../modules/lambda"

  project_name    = var.project_name
  environment     = var.environment
  function_name   = "inventory"
  lambda_zip_path = data.archive_file.inventory_lambda.output_path
  handler         = "lambda.handler"
  runtime         = "nodejs20.x"
  timeout         = 30
  memory_size     = 1024

  environment_variables = {
    DB_HOST          = module.inventory_rds.cluster_endpoint
    DB_PORT          = tostring(module.inventory_rds.cluster_port)
    DB_USERNAME      = var.db_username
    DB_PASSWORD      = var.db_password
    DB_NAME          = module.inventory_rds.database_name
    IDENTITY_API_URL = var.identity_api_url
    NODE_ENV         = var.environment == "prod" ? "production" : "development"
    CORS_ORIGIN      = var.cors_origin
  }

  # VPC Configuration for Lambda to access RDS
  vpc_subnet_ids         = var.vpc_private_subnet_ids
  vpc_security_group_ids = [aws_security_group.lambda.id]

  # Custom IAM policy for Lambda
  enable_custom_policy = true
  custom_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = module.inventory_rds.secret_arn
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      }
    ]
  })

  # Connect to API Gateway
  enable_api_gateway_permission = true
  api_gateway_id                = var.api_gateway_id
  api_gateway_execution_arn     = var.api_gateway_execution_arn

  log_retention_days = var.log_retention_days

  tags = var.tags
}

# RDS Aurora Serverless Module
module "inventory_rds" {
  source = "../../modules/rds-aurora"

  project_name    = var.project_name
  environment     = var.environment
  cluster_name    = "inventory"
  database_name   = "inventory_db"
  master_username = var.db_username
  master_password = var.db_password

  # Aurora Serverless v2 capacity
  min_capacity = var.db_min_capacity
  max_capacity = var.db_max_capacity

  # VPC Configuration
  vpc_id                  = var.vpc_id
  subnet_ids              = var.vpc_private_subnet_ids
  allowed_security_groups = [aws_security_group.lambda.id]

  # Backup Configuration
  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot

  # CloudWatch Logs
  enabled_cloudwatch_logs_exports = ["postgresql"]
  log_retention_days              = var.log_retention_days

  tags = var.tags
}

# Security Group for Lambda
resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-inventory-lambda-${var.environment}-sg"
  description = "Security group for Inventory Lambda function"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name        = "${var.project_name}-inventory-lambda-${var.environment}-sg"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# API Gateway Integration for Inventory Lambda
resource "aws_apigatewayv2_integration" "inventory" {
  api_id           = var.api_gateway_id
  integration_type = "AWS_PROXY"
  integration_uri  = module.inventory_lambda.invoke_arn

  payload_format_version = "2.0"
}

# API Gateway Routes for Inventory Service
# Products Routes
resource "aws_apigatewayv2_route" "inventory_products" {
  api_id    = var.api_gateway_id
  route_key = "ANY /api/products/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.inventory.id}"
}

resource "aws_apigatewayv2_route" "inventory_products_root" {
  api_id    = var.api_gateway_id
  route_key = "ANY /api/products"
  target    = "integrations/${aws_apigatewayv2_integration.inventory.id}"
}

# Warehouses Routes
resource "aws_apigatewayv2_route" "inventory_warehouses" {
  api_id    = var.api_gateway_id
  route_key = "ANY /api/warehouses/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.inventory.id}"
}

resource "aws_apigatewayv2_route" "inventory_warehouses_root" {
  api_id    = var.api_gateway_id
  route_key = "ANY /api/warehouses"
  target    = "integrations/${aws_apigatewayv2_integration.inventory.id}"
}
