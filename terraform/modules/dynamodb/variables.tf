variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  description = "Read capacity units (for PROVISIONED mode)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units (for PROVISIONED mode)"
  type        = number
  default     = 5
}

variable "hash_key" {
  description = "Hash key attribute name"
  type        = string
}

variable "range_key" {
  description = "Range key attribute name (optional)"
  type        = string
  default     = null
}

variable "attributes" {
  description = "List of attribute definitions"
  type = list(object({
    name = string
    type = string # S (string), N (number), B (binary)
  }))
}

variable "global_secondary_indexes" {
  description = "Global secondary indexes"
  type        = list(any)
  default     = []
}

variable "local_secondary_indexes" {
  description = "Local secondary indexes"
  type        = list(any)
  default     = []
}

variable "ttl_enabled" {
  description = "Enable TTL"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "TTL attribute name"
  type        = string
  default     = "ttl"
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "stream_enabled" {
  description = "Enable DynamoDB stream"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption (optional)"
  type        = string
  default     = null
}

variable "autoscaling_enabled" {
  description = "Enable auto-scaling (for PROVISIONED mode)"
  type        = bool
  default     = false
}

variable "autoscaling_read_max_capacity" {
  description = "Max read capacity for auto-scaling"
  type        = number
  default     = 100
}

variable "autoscaling_write_max_capacity" {
  description = "Max write capacity for auto-scaling"
  type        = number
  default     = 100
}

variable "autoscaling_read_target_value" {
  description = "Target value for read capacity auto-scaling"
  type        = number
  default     = 70
}

variable "autoscaling_write_target_value" {
  description = "Target value for write capacity auto-scaling"
  type        = number
  default     = 70
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
