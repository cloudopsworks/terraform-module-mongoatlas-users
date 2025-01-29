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