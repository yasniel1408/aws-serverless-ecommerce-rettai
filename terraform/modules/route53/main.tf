resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-zone"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}
