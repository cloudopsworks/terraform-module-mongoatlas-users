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
  name_prefix: "atlas" # (Required) A prefix for the name of the cluster, used when username is not provided.
  EOD
  type        = string
}

variable "project_id" {
  description = <<-EOD
  project_id: "60f0f0f0f0f0f0f0f0f0f0f0" # (Optional) The ID of the project where the cluster will be created. Default: "".
  EOD
  type        = string
  default     = ""
}

variable "project_name" {
  description = <<-EOD
  project_name: "my-project" # (Optional) The name of the project where the cluster will be created. Default: "".
  EOD
  type        = string
  default     = ""
}

variable "users" {
  description = <<-EOD
  users:
    user1:
      username: "user1"  # (Optional) Uses this value for the name of the user. Default: generated using name_prefix and system names.
      name_prefix: "prefix1" # (Optional) If omitted var.name_prefix is used.
      auth_database: "admin" # (Optional) The database against which the user authenticates. Default: "admin".
      password_rotation_period: 90 # (Optional) Password rotation period in days for this specific user. Default: var.password_rotation_period.
      roles: # (Required) List of roles for the user.
        - role_name: "readWrite" # (Required) Name of the role. Possible values: readWrite, read, dbAdmin, etc.
          database_name: "test" # (Required) Database to which the role applies.
          collection_name: "test" # (Optional) Collection to which the role applies.
      scopes: # (Optional) List of scopes for the user.
        - name: "cluster-name" # (Required) Name of the cluster or data lake.
          type: "CLUSTER" # (Optional) Type of the scope. Possible values: CLUSTER, DATA_LAKE. Default: "CLUSTER".
      connection_strings: # (Optional) Connection strings settings for the user.
        enabled: false # (Optional) Whether to enable connection strings in secrets. Default: false.
        cluster: "test" # (Required if enabled) Name of the cluster.
        endpoint_id: "vpce-xxxxxyyyzzz" # (Optional) Private endpoint ID.
        database_name: "mydatabase" # (Optional) Database name for the connection string.
  EOD
  type        = any
  default     = {}
}

variable "hoop" {
  description = <<-EOD
  hoop:
    enabled: false # (Optional) Whether to enable Hoop.dev connection. Default: false.
    agent: "my-agent" # (Required if enabled) Hoop.dev agent name.
    tags: # (Optional) List of tags for the Hoop connection.
      - "tag1"
  EOD
  type        = any
  default     = {}
}

variable "run_hoop" {
  description = <<-EOD
  run_hoop: false # (Optional) Run hoop with agent, be careful with this option, it will run the HOOP command in output in a null_resource. Default: false.
  EOD
  type        = bool
  default     = false
}

variable "rotation_lambda_name" {
  description = <<-EOD
  rotation_lambda_name: "" # (Optional) Name of the lambda function to rotate the password. Default: "".
  EOD
  type        = string
  default     = ""
  nullable    = false
}

variable "password_rotation_period" {
  description = <<-EOD
  password_rotation_period: 90 # (Optional) Password rotation period in days. Default: 90.
  EOD
  type        = number
  default     = 90
  nullable    = false
}

variable "rotation_duration" {
  description = <<-EOD
  rotation_duration: "1h" # (Optional) Duration of the lambda function to rotate the password. Default: "1h".
  EOD
  type        = string
  default     = "1h"
  nullable    = false
}

variable "rotate_immediately" {
  description = <<-EOD
  rotate_immediately: false # (Optional) Rotate the password immediately. Default: false.
  EOD
  type        = bool
  default     = false
  nullable    = false
}

variable "force_reset" {
  description = <<-EOD
  force_reset: false # (Optional) Force Reset the password. Default: false.
  EOD
  type        = bool
  default     = false
}

variable "secrets_kms_key_id" {
  description = <<-EOD
  secrets_kms_key_id: "alias/aws/secretsmanager" # (Optional) KMS Key ID to use to encrypt data in this secret, can be ARN or KMS Alias. Default: null.
  EOD
  type        = string
  default     = null
}
