# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-${var.environment}-users"

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Auto-verify email
  auto_verified_attributes = ["email"]

  # Username attributes
  username_attributes = ["email"]

  # Username configuration
  username_configuration {
    case_sensitive = false
  }

  # Password policy
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Schema attributes
  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = false
    mutable             = true
  }

  schema {
    name                     = "role"
    attribute_data_type      = "String"
    required                 = false
    mutable                  = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  # MFA configuration
  mfa_configuration = var.mfa_configuration

  # Device tracking
  device_configuration {
    challenge_required_on_new_device      = false
    device_only_remembered_on_user_prompt = true
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-users"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.project_name}-${var.environment}-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # OAuth configuration
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls
  supported_identity_providers         = concat(["COGNITO"], var.enable_google ? ["Google"] : [])

  # PKCE configuration
  generate_secret = false # Must be false for PKCE
  
  # Token validity
  access_token_validity  = var.access_token_validity
  id_token_validity      = var.id_token_validity
  refresh_token_validity = var.refresh_token_validity

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  # Enable token revocation
  enable_token_revocation = true

  # Prevent user existence errors
  prevent_user_existence_errors = "ENABLED"

  # Read/Write attributes
  read_attributes  = ["email", "name", "custom:role"]
  write_attributes = ["email", "name", "custom:role"]

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_CUSTOM_AUTH"
  ]
}

# Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.project_name}-${var.environment}-auth"
  user_pool_id = aws_cognito_user_pool.main.id
}

# Google Identity Provider (optional)
resource "aws_cognito_identity_provider" "google" {
  count = var.enable_google ? 1 : 0

  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email profile openid"
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
  }

  attribute_mapping = {
    email    = "email"
    name     = "name"
    username = "sub"
  }
}

# Cognito User Pool Resource Server (for custom scopes)
resource "aws_cognito_resource_server" "api" {
  identifier   = "${var.project_name}-api"
  name         = "${var.project_name} API"
  user_pool_id = aws_cognito_user_pool.main.id

  scope {
    scope_name        = "admin"
    scope_description = "Admin access to all resources"
  }

  scope {
    scope_name        = "read"
    scope_description = "Read access to resources"
  }

  scope {
    scope_name        = "write"
    scope_description = "Write access to resources"
  }
}
