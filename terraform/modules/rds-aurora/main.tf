# RDS Aurora Serverless v2 Cluster
resource "aws_rds_cluster" "main" {
  cluster_identifier        = "${var.project_name}-${var.cluster_name}-${var.environment}"
  engine                    = "aurora-postgresql"
  engine_mode               = "provisioned"
  engine_version            = var.engine_version
  database_name             = var.database_name
  master_username           = var.master_username
  master_password           = var.master_password
  backup_retention_period   = var.backup_retention_period
  preferred_backup_window   = var.preferred_backup_window
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-${var.cluster_name}-${var.environment}-final-snapshot"

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  serverlessv2_scaling_configuration {
    max_capacity = var.max_capacity
    min_capacity = var.min_capacity
  }

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = merge(
    {
      Name        = "${var.project_name}-${var.cluster_name}-${var.environment}"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# RDS Aurora Serverless v2 Instance
resource "aws_rds_cluster_instance" "main" {
  count              = var.instance_count
  identifier         = "${var.project_name}-${var.cluster_name}-${var.environment}-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version

  publicly_accessible = var.publicly_accessible

  tags = merge(
    {
      Name        = "${var.project_name}-${var.cluster_name}-${var.environment}-instance-${count.index + 1}"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.cluster_name}-${var.environment}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    {
      Name        = "${var.project_name}-${var.cluster_name}-${var.environment}-subnet-group"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.cluster_name}-${var.environment}-rds-sg"
  description = "Security group for RDS Aurora cluster"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from Lambda"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.cluster_name}-${var.environment}-rds-sg"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# CloudWatch Log Group for RDS logs (optional)
resource "aws_cloudwatch_log_group" "rds" {
  for_each = toset(var.enabled_cloudwatch_logs_exports)

  name              = "/aws/rds/cluster/${aws_rds_cluster.main.cluster_identifier}/${each.value}"
  retention_in_days = var.log_retention_days

  tags = merge(
    {
      Name        = "${var.project_name}-${var.cluster_name}-${var.environment}-${each.value}-logs"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# Secrets Manager for DB credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.project_name}/${var.environment}/${var.cluster_name}/credentials"
  description = "Database credentials for ${var.cluster_name}"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.cluster_name}-${var.environment}-credentials"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.master_username
    password = var.master_password
    host     = aws_rds_cluster.main.endpoint
    port     = aws_rds_cluster.main.port
    database = var.database_name
  })
}
