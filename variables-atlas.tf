##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

variable "name_prefix" {
  description = <<-EOD
  name_prefix: "atlas" # (Required) Prefix used to compose usernames when `users[<key>].username` is not provided. Allowed: lowercase letters, numbers, and hyphens. No default.
  EOD
  type        = string
}

variable "project_id" {
  description = <<-EOD
  project_id: "60f0f0f0f0f0f0f0f0f0f0f0" # (Optional) Atlas Project ID. One of `project_id` or `project_name` must be provided. Default: "".
  EOD
  type        = string
  default     = ""
}

variable "project_name" {
  description = <<-EOD
  project_name: "my-project" # (Optional) Atlas Project Name. One of `project_id` or `project_name` must be provided. Default: "".
  EOD
  type        = string
  default     = ""
}

variable "users" {
  description = <<-EOD
  users:
    <user_key>:
      username: "user1" # (Optional) Explicit username. If omitted, composed as `<name_prefix|user.name_prefix>-<system_name_short>-<user_key>`. Default: generated.
      name_prefix: "prefix1" # (Optional) Per-user prefix to build the username. If omitted, uses var.name_prefix. Default: null.
      auth_database: "admin" # (Optional) Authentication database. Common: "admin". Default: "admin".
      password_rotation_period: 90 # (Optional) Rotation period in days for this user. Overrides var.password_rotation_period. Default: var.password_rotation_period.
      roles: # (Required) MongoDB roles granted to this user.
        - role_name: "readWrite" # (Required) Built-in or custom role name. Common built-ins: read, readWrite, dbAdmin, dbOwner, userAdmin, clusterAdmin. No default.
          database_name: "test" # (Required) Database that the role applies to (e.g., "admin", "test", "app_db"). No default.
          collection_name: "widgets" # (Optional) Collection the role is scoped to (if applicable). Default: null.
      scopes: # (Optional) Atlas scope bindings for the user.
        - name: "cluster-name" # (Required) Target cluster or data lake name. No default.
          type: "CLUSTER" # (Optional) Scope type. Allowed: CLUSTER, DATA_LAKE. Default: "CLUSTER".
      connection_strings: # (Optional) Control generation of connection strings in Secrets Manager.
        enabled: false # (Optional) When true, store public/private connection strings for `cluster`. Default: false.
        cluster: "cluster0" # (Required if enabled) Atlas Cluster name used to resolve connection strings. No default.
        endpoint_id: "vpce-0123456789abcdef" # (Optional) Private endpoint ID to build PrivateLink connection strings. Default: "".
        database_name: "mydatabase" # (Optional) Database name appended in the connection string. Default: "".
  EOD
  type        = any
  default     = {}
}

variable "hoop" {
  description = <<-EOD
  hoop:
    enabled: false # (Optional) Enable Hoop.dev connection helper output and resources. Default: false.
    agent: "my-agent" # (Required if enabled) Hoop.dev agent name to use for the tunnel/session. No default.
    tags: # (Optional) Free-form tags to annotate the Hoop connection. Default: [].
      - "mongodb"
      - "production"
  EOD
  type        = any
  default     = {}
}

variable "run_hoop" {
  description = <<-EOD
  run_hoop: false # (Optional) Execute Hoop command via a null_resource (side effect). Use with care. Default: false.
  EOD
  type        = bool
  default     = false
}

variable "rotation_lambda_name" {
  description = <<-EOD
  rotation_lambda_name: "" # (Optional) Name of the AWS Lambda used by Secrets Manager for credential rotation. When set, rotation is managed by Secrets Manager; when empty, passwords are rotated locally via `time_rotating`. Default: "".
  EOD
  type        = string
  default     = ""
  nullable    = false
}

variable "password_rotation_period" {
  description = <<-EOD
  password_rotation_period: 90 # (Optional) Default rotation period in days for all users (overridden by `users[*].password_rotation_period`). Allowed: 1-365. Default: 90.
  EOD
  type        = number
  default     = 90
  nullable    = false
}

variable "rotation_duration" {
  description = <<-EOD
  rotation_duration: "1h" # (Optional) Max runtime for the rotation Lambda. Format: "1h", "2h30m" (AWS Secrets Manager duration). Default: "1h".
  EOD
  type        = string
  default     = "1h"
  nullable    = false
}

variable "rotate_immediately" {
  description = <<-EOD
  rotate_immediately: false # (Optional) When rotation is enabled (rotation_lambda_name != ""), rotate immediately on enable/update. Default: false.
  EOD
  type        = bool
  default     = false
  nullable    = false
}

variable "force_reset" {
  description = <<-EOD
  force_reset: false # (Optional) Force-reset credentials even if unchanged (useful for break-glass scenarios). Default: false.
  EOD
  type        = bool
  default     = false
}

variable "secrets_kms_key_id" {
  description = <<-EOD
  secrets_kms_key_id: "alias/aws/secretsmanager" # (Optional) KMS Key ID/ARN or Alias used for AWS Secrets Manager encryption. Examples: "alias/aws/secretsmanager", "arn:aws:kms:us-east-1:123456789012:key/mrk-...". Default: null.
  EOD
  type        = string
  default     = null
}
