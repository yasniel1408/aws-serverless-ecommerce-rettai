# Identity Lambda

Lambda function for authentication and authorization.

## Features

### Authentication
- **Cognito PKCE Flow**: Secure authentication with Proof Key for Code Exchange
- **Google OAuth**: Social login with Google
- **Token Management**: Access tokens, ID tokens, and refresh tokens

### Authorization
- **AWS Verified Permissions**: Policy-based authorization
- **Role-Based Access Control (RBAC)**: Admin and user roles
- **Lambda Authorizer**: Protects API Gateway routes

### User Management
- **DynamoDB Storage**: User profiles stored in `identity-db` table
- **Profile Management**: GET/UPDATE user profiles

## API Endpoints

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

## Lambda Authorizer

This function also serves as an API Gateway Lambda Authorizer.

### Admin Access
- Checks if user has `admin` role
- Uses AWS Verified Permissions to validate access
- Returns IAM policy for API Gateway

## Environment Variables

- `USER_POOL_ID`: Cognito User Pool ID
- `CLIENT_ID`: Cognito App Client ID
- `TABLE_NAME`: DynamoDB table name (identity-db)
- `POLICY_STORE_ID`: AWS Verified Permissions policy store ID
- `AWS_REGION`: AWS region

## Roles

### Admin
- Full access to admin panel
- Full access to all resources

### User (default)
- Access to user resources only
- No admin panel access

## DynamoDB Schema

```javascript
{
  userId: "cognito-sub-id",
  username: "user@example.com",
  email: "user@example.com",
  name: "John Doe",
  role: "admin" | "user",
  provider: "cognito" | "google",
  lastLogin: "2024-01-01T00:00:00Z",
  createdAt: "2024-01-01T00:00:00Z",
  updatedAt: "2024-01-01T00:00:00Z"
}
```

## Development

```bash
npm install
npm test
npm run build
```

## Deployment

Deployed via Terraform in `terraform/systems/identity-lambda/`
