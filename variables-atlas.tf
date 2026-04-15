##
# (c) 2021-2026
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

variable "region" {
  description = <<-EOD
  region: "us-east-1" # (Optional) Cloud provider region identifier used in system_name_short composition for username generation. Passed from cloud-specific wrapper modules. Default: "".
  EOD
  type        = string
  default     = ""
  nullable    = false
}

variable "users" {
  description = <<-EOD
  users:
    <user_key>:
      username: "user1" # (Optional) Explicit username. If omitted, composed as `<name_prefix|user.name_prefix>-<system_name_short>-<user_key>`. Default: generated.
      name_prefix: "prefix1" # (Optional) Per-user prefix to build the username. If omitted, uses var.name_prefix. Default: null.
      auth_database: "admin" # (Optional) Authentication database. Common: "admin". Default: "admin".
      password_rotation_period: 90 # (Optional) Rotation period in days for this user. Overrides var.password_rotation_period. Default: var.password_rotation_period.
      import: false # (Optional) When true, imports an existing MongoDB Atlas user instead of creating a new one. Default: false.
      role_name: "readwrite" # (Optional) Top-level primary role key used for Hoop connection naming. Allowed: readwrite, read, dbadmin, admin, dbowner, owner, clusteradmin. Default: "default".
      roles: # (Required) MongoDB roles granted to this user.
        - role_name: "readWrite" # (Required) Built-in or custom role name. Common built-ins: read, readWrite, dbAdmin, dbOwner, userAdmin, clusterAdmin. No default.
          database_name: "test" # (Required) Database that the role applies to (e.g., "admin", "test", "app_db"). No default.
          collection_name: "widgets" # (Optional) Collection the role is scoped to (if applicable). Default: null.
      scopes: # (Optional) Atlas scope bindings for the user.
        - name: "cluster-name" # (Required) Target cluster or data lake name. No default.
          type: "CLUSTER" # (Optional) Scope type. Allowed: CLUSTER, DATA_LAKE. Default: "CLUSTER".
      connection_strings: # (Optional) Control generation of connection strings in Secrets Manager.
        enabled: false # (Optional) When true, include connection strings in credentials output. Default: false.
        cluster: "cluster0" # (Required if enabled) Atlas Cluster name used to resolve connection strings. No default.
        endpoint_id: "vpce-0123456789abcdef" # (Optional) Private endpoint ID to build PrivateLink connection strings. Default: "".
        database_name: "mydatabase" # (Optional) Database name appended in the connection string. Default: "".
      hoop: # (Optional) Per-user Hoop.dev integration overrides.
        import: false # (Optional) When true, imports this user's existing Hoop connection instead of creating a new one. Default: false.
        access_control: [] # (Optional) Per-user access control list merged with global hoop.access_control. Default: [].
  EOD
  type        = any
  default     = {}
}

variable "hoop" {
  description = <<-EOD
  hoop:
    enabled: false # (Optional) Enable Hoop.dev connection metadata output. Default: false.
    agent_id: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" # (Required if enabled) Hoop.dev agent ID (UUID) for hoop_output generation. No default.
    tags: # (Optional) Free-form tags to annotate the Hoop connection. Default: {}.
      key: "value"
    access_control: [] # (Optional) Global access control list applied to all Hoop connections. Merged with per-user users[*].hoop.access_control. Default: [].
  EOD
  type        = any
  default     = {}
}

variable "password_rotation_period" {
  description = <<-EOD
  password_rotation_period: 90 # (Optional) Default rotation period in days for all users (overridden by `users[*].password_rotation_period`). Allowed: 1-365. Default: 90.
  EOD
  type        = number
  default     = 90
  nullable    = false
}

variable "password_externally_managed" {
  description = <<-EOD
  password_externally_managed: false # (Optional) When true, the module sets an initial password but does not auto-rotate via time_rotating. Use when an external system (e.g. AWS Lambda, GCP Cloud Function, Azure Function) manages password rotation. Default: false.
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
