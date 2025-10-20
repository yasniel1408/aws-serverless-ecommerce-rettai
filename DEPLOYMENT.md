# Deployment Guide - AWS Serverless E-commerce

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Node.js >= 20.x
- GitHub Personal Access Token with `repo` and `admin:repo_hook` permissions

## Step-by-Step Deployment

### 1. Update GitHub Token

The current GitHub token is expired. Create a new one:

1. Go to https://github.com/settings/tokens/new
2. Select scopes: `repo` and `admin:repo_hook`
3. Generate token and copy it
4. Update `terraform/terraform.tfvars`:
   ```hcl
   github_token = "YOUR_NEW_TOKEN_HERE"
   ```

### 2. Configure Variables

Edit `terraform/terraform.tfvars` with your values:

```hcl
# Basic Configuration
project_name = "rettai"
environment  = "dev"
domain_name  = "rettai.com"
aws_region   = "us-east-1"

# Route53
existing_route53_zone_id = "YOUR_ZONE_ID"

# GitHub
github_repository = "https://github.com/yasniel1408/aws-serverless-ecommerce-rettai"
github_token      = "YOUR_NEW_TOKEN"

# Database (IMPORTANT: Use a strong password!)
inventory_db_password = "YourSecurePassword123!@#"

# Cost Optimization for Development
inventory_db_min_capacity     = 0.5  # Minimum cost
inventory_db_max_capacity     = 1    # Keep it low for dev
inventory_db_skip_final_snapshot = true  # Skip snapshot in dev
```

### 3. Build Lambda Functions

```bash
# From project root
./scripts/build-lambdas.sh
```

This will:
- Install dependencies for both Lambdas
- Build TypeScript for Inventory Lambda
- Create ZIP packages in `terraform/.terraform/tmp/`

### 4. Deploy Infrastructure

```bash
cd terraform

# Initialize Terraform (if not done already)
terraform init

# Review the plan
terraform plan

# Apply (this will take 10-15 minutes)
terraform apply
```

### 5. What Gets Created

#### VPC Resources
- VPC (10.0.0.0/16)
- 2 Public subnets (10.0.1.0/24, 10.0.2.0/24)
- 2 Private subnets (10.0.11.0/24, 10.0.12.0/24)
- Internet Gateway
- 2 NAT Gateways (⚠️ $32/month each)
- Route Tables

#### API Gateway
- HTTP API Gateway
- Custom domain (api.rettai.com)
- SSL certificate
- CloudWatch Logs

#### Identity Lambda
- Lambda function (Node.js 20.x)
- Cognito User Pool
- DynamoDB table (identity-db)
- Verified Permissions policy store
- API Gateway routes (/auth/*)

#### Inventory Lambda
- Lambda function (NestJS, Node.js 20.x, 1GB RAM)
- RDS Aurora Serverless v2 (PostgreSQL)
- Security Groups
- Secrets Manager (DB credentials)
- API Gateway routes (/api/products, /api/warehouses)

#### Amplify Apps
- Web Rettai (rettai.com)
- Web Rettai Admin (admin.rettai.com)

### 6. Post-Deployment

#### Verify Deployment
```bash
# Check outputs
terraform output

# Test API Gateway
curl https://api.rettai.com
```

#### Create First Admin User

You'll need to create an admin user in Cognito:

```bash
# Get Cognito User Pool ID
USER_POOL_ID=$(terraform output -raw identity_cognito_user_pool_id)

# Create admin user
aws cognito-idp admin-create-user \
  --user-pool-id $USER_POOL_ID \
  --username admin@example.com \
  --user-attributes Name=email,Value=admin@example.com Name=custom:role,Value=admin \
  --temporary-password "TempPassword123!" \
  --message-action SUPPRESS

# Set permanent password
aws cognito-idp admin-set-user-password \
  --user-pool-id $USER_POOL_ID \
  --username admin@example.com \
  --password "YourAdminPassword123!" \
  --permanent
```

#### Initialize Database

The Inventory Lambda will auto-create tables on first run (TypeORM synchronize is enabled in dev).

To manually initialize:

```bash
# Get RDS endpoint
RDS_ENDPOINT=$(terraform output -raw inventory_rds_endpoint)

# Connect via bastion or VPN
psql -h $RDS_ENDPOINT -U inventory_admin -d inventory_db
```

### 7. Test the System

#### Test Identity Lambda
```bash
# Login
curl -X POST https://api.rettai.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin@example.com",
    "password": "YourAdminPassword123!"
  }'

# Save the access token from response
TOKEN="<access_token_from_response>"

# Get user info
curl https://api.rettai.com/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

#### Test Inventory Lambda
```bash
# Create a product (Admin only)
curl -X POST https://api.rettai.com/api/products \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Product",
    "sku": "PROD-001",
    "price": 99.99,
    "quantity": 100
  }'

# List products
curl https://api.rettai.com/api/products \
  -H "Authorization: Bearer $TOKEN"

# Create a warehouse
curl -X POST https://api.rettai.com/api/warehouses \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Main Warehouse",
    "code": "WH-001",
    "type": "main",
    "capacity": 10000,
    "address": {
      "street": "123 Main St",
      "city": "Miami",
      "state": "FL",
      "zipCode": "33101",
      "country": "USA"
    }
  }'
```

## Cost Breakdown (Development)

### Monthly Costs
- **VPC (2 NAT Gateways)**: ~$64/month
- **Aurora Serverless v2 (0.5-1 ACU)**: ~$40-80/month
- **API Gateway**: ~$1/month (first 1M requests free)
- **Lambda**: Free tier covers development
- **Amplify**: ~$0.15/build minute + hosting
- **CloudWatch Logs**: ~$0.50/month
- **Secrets Manager**: ~$0.40/month

**Total**: ~$110-150/month

### Cost Optimization Tips
1. **Use single NAT Gateway** instead of 2 (saves $32/month)
2. **Pause Aurora** when not in use
3. **Use VPC Endpoints** to avoid NAT Gateway charges
4. **Set `skip_final_snapshot = true`** for dev environments
5. **Reduce log retention** to 1-3 days

## Troubleshooting

### Lambda Cold Starts
First requests may take 5-10 seconds. This is normal for Lambda in VPC.

### RDS Connection Issues
- Verify Lambda security group can reach RDS security group
- Check NAT Gateway is routing correctly
- Verify RDS is in same VPC as Lambda

### GitHub Token Issues
- Token must have `repo` and `admin:repo_hook` scopes
- Token must not be expired
- Verify repository URL is correct

### Amplify Build Failures
- Check GitHub token permissions
- Verify build spec paths are correct
- Check Node.js version in Amplify settings

## Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy
```

⚠️ **Warning**: This will delete:
- All databases (including data)
- All Lambda functions
- VPC and networking
- Amplify apps

Make sure to backup any important data first!

## Next Steps

1. **Set up CI/CD**: Automate Lambda builds and deployments
2. **Add Monitoring**: CloudWatch dashboards and alarms
3. **Database Migrations**: Set up TypeORM migrations for production
4. **Security Hardening**: 
   - Rotate secrets regularly
   - Enable WAF for API Gateway
   - Set up AWS CloudTrail
5. **Performance**: 
   - Add caching (ElastiCache)
   - Optimize Lambda bundle sizes
   - Use Lambda Layers for shared dependencies

## Support

For issues or questions:
1. Check Terraform outputs: `terraform output`
2. Check CloudWatch Logs for Lambda errors
3. Verify security group rules
4. Check RDS status in AWS Console
