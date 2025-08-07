##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

variable "name_prefix" {
  description = "(required) A prefix for the name of the cluster"
  type        = string
}

variable "project_id" {
  description = "(optional) The ID of the project where the cluster will be created"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "(optional) The name of the project where the cluster will be created"
  type        = string
  default     = ""
}

##
# YAML Entry Format:
# users:
#   user1:
#     name_prefix: "prefix1" #(optional) if omitted var.name_prefix is used
#     username: "user1"  #(optional) uses this value for the name of the user
#     roles: Documented Here https://www.mongodb.com/docs/atlas/mongodb-users-roles-and-privileges/
#       - role_name: "readWrite"
#         database_name: "test"
#         collection_name: "test" #(optional)
#     scopes:
#       - name: "xxxxxyyyzzz"
#         type: "project" #(optional) default is "CLUSTER"
#     connection_strings:
#       enabled: false #(optional) default is false
#       cluster: "test"
#       endpoint_id: "vpce-xxxxxyyyzzz" #(optional)
#       database_name: "mydatabase" #(optional)
variable "users" {
  description = "(required) Settings for the module"
  type        = any
  default     = {}
}

variable "hoop" {
  description = "(optional) Hoop Settings for the module"
  type        = any
  default     = {}
}

variable "run_hoop" {
  description = "Run hoop with agent, be careful with this option, it will run the HOOP command in output in a null_resource"
  type        = bool
  default     = false
}

variable "rotation_lambda_name" {
  description = "(optional) Name of the lambda function to rotate the password"
  type        = string
  default     = ""
  nullable    = false
}

variable "password_rotation_period" {
  description = "(optional) Password rotation period in days"
  type        = number
  default     = 90
  nullable    = false
}

variable "rotation_duration" {
  description = "(optional) Duration of the lambda function to rotate the password"
  type        = string
  default     = "1h"
  nullable    = false
}

variable "rotate_immediately" {
  description = "(optional) Rotate the password immediately"
  type        = bool
  default     = false
  nullable    = false
}

variable "force_reset" {
  description = "(optional) Force Reset the password"
  type        = bool
  default     = false
}

variable "secrets_kms_key_id" {
  description = "(optional) KMS Key ID to use to encrypt data in this secret, can be ARN or KMS Alias"
  type        = string
  default     = null
}
