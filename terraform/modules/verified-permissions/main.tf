# AWS Verified Permissions Policy Store
resource "aws_verifiedpermissions_policy_store" "main" {
  validation_settings {
    mode = "STRICT"
  }

  description = "Policy store for ${var.project_name} ${var.environment}"
}

# Schema for entities
resource "aws_verifiedpermissions_schema" "main" {
  policy_store_id = aws_verifiedpermissions_policy_store.main.id

  definition {
    value = jsonencode({
      "${var.project_name}::Application" = {
        entityTypes = {
          User = {
            shape = {
              type = "Record"
              attributes = {
                role = {
                  type = "String"
                }
                userId = {
                  type = "String"
                }
              }
            }
          }
          Resource = {
            shape = {
              type       = "Record"
              attributes = {
                ownerId = {
                  type = "String"
                }
              }
            }
          }
        }
        actions = {
          access = {
            appliesTo = {
              principalTypes = ["User"]
              resourceTypes  = ["Resource"]
            }
          }
          read = {
            appliesTo = {
              principalTypes = ["User"]
              resourceTypes  = ["Resource"]
            }
          }
          write = {
            appliesTo = {
              principalTypes = ["User"]
              resourceTypes  = ["Resource"]
            }
          }
          delete = {
            appliesTo = {
              principalTypes = ["User"]
              resourceTypes  = ["Resource"]
            }
          }
        }
      }
    })
  }
}

# Policy: Admin has full access
resource "aws_verifiedpermissions_policy" "admin_full_access" {
  policy_store_id = aws_verifiedpermissions_policy_store.main.id

  definition {
    static {
      description = "Admin role has full access to all resources"
      statement   = <<-EOT
        permit(
          principal,
          action,
          resource
        )
        when {
          principal.role == "admin"
        };
      EOT
    }
  }
}

# Policy: Admin can access admin panel
resource "aws_verifiedpermissions_policy" "admin_panel_access" {
  policy_store_id = aws_verifiedpermissions_policy_store.main.id

  definition {
    static {
      description = "Admin role can access admin panel"
      statement   = <<-EOT
        permit(
          principal,
          action == rettai::Application::Action::"access",
          resource == rettai::Application::Resource::"admin-panel"
        )
        when {
          principal.role == "admin"
        };
      EOT
    }
  }
}

# Policy: Users can read their own resources
resource "aws_verifiedpermissions_policy" "user_read_own" {
  policy_store_id = aws_verifiedpermissions_policy_store.main.id

  definition {
    static {
      description = "Users can read their own resources"
      statement   = <<-EOT
        permit(
          principal,
          action == rettai::Application::Action::"read",
          resource
        )
        when {
          principal.role == "user" &&
          resource.ownerId == principal.userId
        };
      EOT
    }
  }
}
