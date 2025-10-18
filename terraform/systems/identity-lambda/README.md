# Identity Lambda System

This system provides authentication and authorization services for the application.

## Features

### Authentication
- **Cognito PKCE Flow**: Secure authentication with Proof Key for Code Exchange
- **Google OAuth**: Social login with Google (optional)
- **Token Management**: Access tokens, ID tokens, and refresh tokens
- **MFA Support**: Optional multi-factor authentication

### Authorization
- **AWS Verified Permissions**: Policy-based authorization
- **Role-Based Access Control (RBAC)**: Admin and user roles
- **Lambda Authorizer**: Protects API Gateway routes

### User Management
- **DynamoDB Storage**: User profiles in identity-db table
- **Profile Management**: GET/UPDATE user profiles
- **Email Index**: Fast lookup by email

## Resources Created

1. **Lambda Function**: Identity handler function
2. **DynamoDB Table**: User identity storage
3. **Cognito User Pool**: User authentication
4. **Cognito User Pool Client**: OAuth client
5. **Verified Permissions Store**: Authorization policies
6. **IAM Roles**: Lambda execution role with permissions
7. **CloudWatch Log Group**: Function logs
8. **API Gateway Routes**: Authentication endpoints

## API Endpoints

All endpoints are available at: `https://api.{domain}/auth/*`

### POST /auth/login
Cognito PKCE login
```json
{
  "username": "user@example.com",
  "codeVerifier": "...",
  "authCode": "..."
}
```

### POST /auth/google
Google OAuth login
```json
{
  "googleToken": "..."
}
```

### POST /auth/refresh
Refresh access token
```json
{
  "refreshToken": "..."
}
```

### GET /auth/me
Get current user profile (requires Authorization header)

### POST /auth/authorize
Check authorization for resource/action
```json
{
  "resource": "admin-panel",
  "action": "access"
}
```

## Configuration

### Variables

- `project_name`: Project name
- `environment`: Environment (dev, staging, prod)
- `aws_region`: AWS region
- `api_gateway_id`: API Gateway ID to attach routes
- `api_gateway_execution_arn`: API Gateway execution ARN
- `cognito_callback_urls`: OAuth callback URLs
- `cognito_logout_urls`: OAuth logout URLs
- `enable_google_oauth`: Enable Google OAuth (default: false)
- `google_client_id`: Google OAuth client ID
- `google_client_secret`: Google OAuth client secret
- `log_retention_days`: CloudWatch log retention (default: 7 days)

### Outputs

- `lambda_function_name`: Lambda function name
- `lambda_function_arn`: Lambda function ARN
- `cognito_user_pool_id`: Cognito User Pool ID
- `cognito_user_pool_client_id`: Cognito client ID
- `dynamodb_table_name`: DynamoDB table name
- `policy_store_id`: Verified Permissions store ID
- `auth_endpoints`: List of authentication endpoints

## DynamoDB Schema

```javascript
{
  userId: "cognito-sub-id",        // Partition key
  username: "user@example.com",
  email: "user@example.com",       // GSI partition key
  name: "John Doe",
  role: "admin" | "user",
  provider: "cognito" | "google",
  lastLogin: "2024-01-01T00:00:00Z",
  createdAt: "2024-01-01T00:00:00Z",
  updatedAt: "2024-01-01T00:00:00Z"
}
```

## Roles

### Admin
- Full access to admin panel
- Full access to all resources
- User management capabilities

### User (default)
- Access to user resources only
- No admin panel access
- Self profile management

## Lambda Code

The Lambda function code is located at: `lambdas/identity/src/`

To build and deploy:
```bash
cd lambdas/identity
npm install
npm run build
```

Then run Terraform to deploy:
```bash
cd terraform
terraform apply
```

## Dependencies

This system depends on:
- API Gateway system (must be created first)
- DynamoDB module
- Cognito module
- Verified Permissions module
- Lambda module

## Security

- IAM roles follow least privilege principle
- Cognito manages password policies
- Tokens have configurable expiry
- MFA optional but recommended
- CloudWatch logging enabled for audit
