# Inventory Lambda System

NestJS-based inventory management microservice deployed as AWS Lambda with RDS Aurora Serverless PostgreSQL.

## Features

- **NestJS Framework**: Modern, scalable Node.js framework
- **TypeORM**: Database ORM with migrations
- **PostgreSQL**: Aurora Serverless v2 for cost-effective scaling
- **Admin-Only Access**: Protected by JWT authentication
- **VPC Integration**: Lambda and RDS in private subnets
- **Auto-Scaling**: Aurora Serverless scales based on load
- **Secrets Management**: DB credentials in AWS Secrets Manager

## Resources Created

1. **Lambda Function**: Inventory service (1024MB, 30s timeout)
2. **RDS Aurora Cluster**: PostgreSQL serverless v2
3. **RDS Instance**: Auto-scaling (0.5-2 ACU)
4. **Security Groups**: Lambda and RDS security groups
5. **Secrets Manager**: Database credentials
6. **CloudWatch Logs**: Lambda and RDS logs
7. **API Gateway Routes**: Products and warehouses endpoints

## API Endpoints

Base URL: `https://api.{domain}/api`

### Products
- `GET/POST /api/products` - List/create products
- `GET /api/products/:id` - Get product by ID
- `GET /api/products/sku/:sku` - Get product by SKU
- `GET /api/products/low-stock` - Get low stock products
- `PATCH /api/products/:id` - Update product
- `PATCH /api/products/:id/stock` - Update stock
- `DELETE /api/products/:id` - Delete product

### Warehouses
- `GET/POST /api/warehouses` - List/create warehouses
- `GET /api/warehouses/:id` - Get warehouse by ID
- `GET /api/warehouses/code/:code` - Get warehouse by code
- `GET /api/warehouses/:id/capacity` - Get capacity report
- `PATCH /api/warehouses/:id` - Update warehouse
- `DELETE /api/warehouses/:id` - Delete warehouse

## Database Schema

### Products Table
- id (UUID), name, description, sku (unique)
- price, cost, quantity, minStock
- category, brand, unit, isActive
- warehouseId (FK), metadata (JSONB)

### Warehouses Table
- id (UUID), name, code (unique), description
- type, capacity, isActive
- managerName, phone, email

### Warehouse Addresses Table
- id (UUID), street, city, state, zipCode, country
- latitude, longitude, notes
- warehouseId (FK)

## Configuration

### Variables

- `project_name`, `environment`, `aws_region`
- `api_gateway_id`, `api_gateway_execution_arn`
- `identity_api_url` - Identity service URL for auth
- `vpc_id`, `vpc_private_subnet_ids` - VPC configuration
- `db_username`, `db_password` - Database credentials
- `db_min_capacity`, `db_max_capacity` - Aurora scaling (default: 0.5-2 ACU)
- `db_backup_retention_period` - Backup retention (default: 7 days)
- `log_retention_days` - Log retention (default: 7 days)

### Outputs

- `lambda_function_name`, `lambda_function_arn`
- `rds_cluster_endpoint`, `rds_cluster_id`
- `rds_database_name`, `rds_secret_arn`
- `api_endpoints`, `security_group_id`

## Deployment

1. **Build Lambda**:
```bash
cd lambdas/inventory
npm install
npm run build
```

2. **Deploy Infrastructure**:
```bash
cd terraform
terraform apply
```

3. **Run Database Migrations** (if needed):
Connect to RDS and run migrations using TypeORM

## Security

- **VPC Isolation**: Lambda and RDS in private subnets
- **Security Groups**: Lambda can only access RDS on port 5432
- **Admin-Only**: All endpoints require admin JWT token
- **Secrets Manager**: Database credentials encrypted
- **SSL/TLS**: RDS encryption enabled in production

## Authentication

All requests require `Authorization: Bearer <token>` header with admin role.

Example:
```bash
curl -X GET https://api.yourdomain.com/api/products \
  -H "Authorization: Bearer YOUR_ADMIN_JWT_TOKEN"
```

The AdminGuard validates:
1. Valid JWT token from Identity service
2. User has `admin` role

## Cost Optimization

- **Aurora Serverless v2**: Scales to 0.5 ACU (~ $0.12/hour minimum)
- **Lambda**: Pay per request
- **VPC**: NAT Gateway required (consider using VPC endpoints)
- **Logs**: 7-day retention by default

For development, set:
- `db_min_capacity = 0.5`
- `db_max_capacity = 1`
- `db_skip_final_snapshot = true`

## Dependencies

- VPC module with private subnets
- API Gateway system
- Identity Lambda system (for authentication)

## Database Access

To connect to RDS for maintenance:

1. Get credentials from Secrets Manager
2. Use bastion host or VPN
3. Connect via psql:
```bash
psql -h <cluster-endpoint> -U <username> -d inventory_db
```

## Monitoring

- **CloudWatch Logs**: Lambda and RDS logs
- **Metrics**: Lambda invocations, RDS connections
- **Alarms**: Set up for high CPU, low storage

## Troubleshooting

- **Cold starts**: First request may take 5-10s
- **VPC**: Ensure NAT Gateway for Lambda internet access
- **RDS**: Check security group rules
- **Auth**: Verify IDENTITY_API_URL is correct
