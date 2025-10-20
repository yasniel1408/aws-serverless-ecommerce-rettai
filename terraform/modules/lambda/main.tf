# Lambda Function
resource "aws_lambda_function" "main" {
  filename         = var.lambda_zip_path
  function_name    = "${var.project_name}-${var.function_name}-${var.environment}"
  role             = aws_iam_role.lambda.arn
  handler          = var.handler
  source_code_hash = try(filebase64sha256(var.lambda_zip_path), null)
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = var.vpc_subnet_ids != null ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.function_name}-${var.environment}"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )

  lifecycle {
    ignore_changes = [source_code_hash]
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-${var.function_name}-${var.environment}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name        = "${var.project_name}-${var.function_name}-${var.environment}-role"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# Basic Lambda Execution Policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC Execution Policy (if VPC is enabled)
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count      = var.vpc_subnet_ids != null ? 1 : 0
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Custom IAM Policy for Lambda (optional)
resource "aws_iam_role_policy" "lambda_custom" {
  count  = var.enable_custom_policy ? 1 : 0
  name   = "${var.project_name}-${var.function_name}-${var.environment}-custom-policy"
  role   = aws_iam_role.lambda.id
  policy = var.custom_policy_json
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.main.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    {
      Name        = "${var.project_name}-${var.function_name}-${var.environment}-logs"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# Lambda Permission for API Gateway (optional)
resource "aws_lambda_permission" "api_gateway" {
  count         = var.enable_api_gateway_permission ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}
