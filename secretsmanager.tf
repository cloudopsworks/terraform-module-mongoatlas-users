##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  project_name = var.project_name != "" ? var.project_name : data.mongodbatlas_project.this_id[0].name
  project_id   = var.project_id != "" ? var.project_id : data.mongodbatlas_project.this[0].id
  default_roles = {
    readwrite    = "rw"
    read         = "ro"
    dbadmin      = "dba"
    admin        = "dba"
    dbowner      = "ow"
    owner        = "ow"
    clusteradmin = "ca"
  }
  pvt_endpoints = merge([for k, v in data.mongodbatlas_advanced_cluster.cluster : {
    for ep in try(v.connection_strings.0.private_endpoint, []) : "${k}-${ep.endpoints[0].endpoint_id}" => {
      connection     = try(ep.connection_string, "")
      srv_connection = try(ep.srv_connection_string, "")
      pvt            = split("/", try(ep.connection_string, ""))
      pvt_srv        = split("/", try(ep.srv_connection_string, ""))
      endpoint_id    = ep.endpoints[0].endpoint_id
    }
    }
  ]...)
  connection_strings_arrs = {
    for k, v in data.mongodbatlas_advanced_cluster.cluster : k => {
      plain        = try(v.connection_strings.0.standard, v.connection_strings.standard, "")
      plain_srv    = try(v.connection_strings.0.standard_srv, v.connection_strings.standard_srv, "")
      standard     = split("/", try(v.connection_strings.0.standard, v.connection_strings.standard, ""))
      standard_srv = split("/", try(v.connection_strings.0.standard_srv, v.connection_strings.standard_srv, ""))
    }
  }
  user_passwords = {
    for k, v in var.users : k => (var.rotation_lambda_name == "" ? random_password.randompass[k].result : random_password.randompass_rotated[k].result)
  }
  mongodb_credentials_conn_raw = {
    for k, v in var.users : k => {
      auth_database                 = try(v.auth_database, "admin")
      username                      = local.user_names_list[k]
      password                      = local.user_passwords[k]
      project_name                  = local.project_name
      project_id                    = local.project_id
      engine                        = "mongodbatlas"
      dbname                        = try(v.connection_strings.database_name, "")
      url                           = local.connection_strings_arrs[v.connection_strings.cluster].plain
      url_srv                       = local.connection_strings_arrs[v.connection_strings.cluster].plain_srv
      private_url                   = try(local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].connection, "")
      private_url_srv               = try(local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].srv_connection, "")
      connection_string             = length(local.connection_strings_arrs[v.connection_strings.cluster].standard) > 1 ? format("%s//%s:%s@%s/%s%s", local.connection_strings_arrs[v.connection_strings.cluster].standard[0], local.user_names_list[k], local.user_passwords[k], local.connection_strings_arrs[v.connection_strings.cluster].standard[2], try(v.connection_strings.database_name, ""), local.connection_strings_arrs[v.connection_strings.cluster].standard[3]) : ""
      connection_string_srv         = length(local.connection_strings_arrs[v.connection_strings.cluster].standard_srv) > 1 ? format("%s//%s:%s@%s/%s%s", local.connection_strings_arrs[v.connection_strings.cluster].standard_srv[0], local.user_names_list[k], local.user_passwords[k], local.connection_strings_arrs[v.connection_strings.cluster].standard_srv[2], try(v.connection_strings.database_name, ""), local.connection_strings_arrs[v.connection_strings.cluster].standard[3]) : ""
      private_connection_string     = length(try(local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt, [])) > 1 ? format("%s//%s:%s@%s/%s%s", local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt[0], local.user_names_list[k], local.user_passwords[k], local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt[2], try(v.connection_strings.database_name, ""), local.connection_strings_arrs[v.connection_strings.cluster].standard[3]) : ""
      private_connection_string_srv = length(try(local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt_srv, [])) > 1 ? format("%s//%s:%s@%s/%s%s", local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt_srv[0], local.user_names_list[k], local.user_passwords[k], local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt_srv[2], try(v.connection_strings.database_name, ""), local.connection_strings_arrs[v.connection_strings.cluster].standard[3]) : ""
      endpoint_id                   = try(v.connection_strings.endpoint_id, "")
    } if try(v.connection_strings.enabled, false)
  }
  mongodb_credentials_conn = {
    for k, user in local.mongodb_credentials_conn_raw : k => {
      for p, v in user : p => v if v != "" && v != null
    }
  }
  mongodb_credentials_noconn = {
    for k, v in var.users : k => {
      username      = local.user_names_list[k]
      password      = local.user_passwords[k]
      auth_database = try(v.auth_database, "admin")
      project_name  = local.project_name
      project_id    = local.project_id
      engine        = "mongodbatlas"
    } if !try(v.connection_strings.enabled, false)
  }

  mongodb_credentials = merge(local.mongodb_credentials_conn, local.mongodb_credentials_noconn)
  name_list = {
    for k, v in var.users : k => format("%s/mongodbatlas/%s/%s-connstrings",
      local.secret_store_path,
      lower(replace(replace(local.project_name, " ", ""), "_", "-")),
      lower(replace(k, "_", "-")),
    )
  }
}

# Secrets saving
resource "aws_secretsmanager_secret" "atlas_cred_conn" {
  for_each    = var.users
  description = "MongoDB User Credentials - ${local.user_names_list[each.key]} - ${local.project_name}${try(var.users[each.key].connection_strings.database_name, "") != "" ? format(" - %s", var.users[each.key].connection_strings.database_name) : ""}"
  name        = local.name_list[each.key]
  kms_key_id  = var.secrets_kms_key_id
  tags = merge(local.all_tags, {
    "mongodb-username" = local.user_names_list[each.key]
    "mongodb-project"  = local.project_name
    },
    try(var.users[each.key].connection_strings.database_name, "") != "" ? { "mongodb-dbname" = try(var.users[each.key].connection_strings.database_name, "") } : {}
  )
  depends_on = [
    mongodbatlas_database_user.this
  ]
}

resource "aws_secretsmanager_secret_version" "atlas_cred_conn" {
  for_each = {
    for k, v in var.users : k => v if var.rotation_lambda_name == ""
  }
  secret_id     = aws_secretsmanager_secret.atlas_cred_conn[each.key].id
  secret_string = jsonencode(local.mongodb_credentials[each.key])
}

## Rotation Enabled
data "aws_secretsmanager_secrets" "atlas_cred_conn_rotated" {
  for_each = {
    for k, v in var.users : k => v if var.rotation_lambda_name != ""
  }
  filter {
    name = "name"
    values = [
      local.name_list[each.key]
    ]
  }
}

data "aws_secretsmanager_secret_versions" "atlas_cred_conn_rotated" {
  for_each = {
  for k, v in var.users : k => v if var.rotation_lambda_name != "" && length(try(data.aws_secretsmanager_secrets.atlas_cred_conn_rotated[k].names, [])) > 0 }
  secret_id          = local.name_list[each.key]
  include_deprecated = true
}

data "aws_secretsmanager_secret_version" "atlas_cred_conn_rotated" {
  for_each = {
    for k, v in var.users : k => v if var.rotation_lambda_name != "" && length(try(data.aws_secretsmanager_secrets.atlas_cred_conn_rotated[k].names, [])) > 0 && length(try(data.aws_secretsmanager_secret_versions.atlas_cred_conn_rotated[k].versions, [])) > 0
  }
  secret_id = local.name_list[each.key]
}

data "aws_lambda_function" "rotation_function" {
  count         = var.rotation_lambda_name != "" ? 1 : 0
  function_name = var.rotation_lambda_name
}

resource "aws_secretsmanager_secret_version" "atlas_cred_conn_rotated" {
  for_each = {
    for k, v in var.users : k => v if var.rotation_lambda_name != ""
  }
  secret_id     = aws_secretsmanager_secret.atlas_cred_conn[each.key].id
  secret_string = jsonencode(local.mongodb_credentials[each.key])
  lifecycle {
    ignore_changes = [
      secret_string,
      version_stages
    ]
  }
}

resource "aws_secretsmanager_secret_rotation" "atlas_cred_conn_rotation" {
  for_each = {
    for k, v in var.users : k => v if var.rotation_lambda_name != ""
  }
  secret_id           = aws_secretsmanager_secret.atlas_cred_conn[each.key].id
  rotation_lambda_arn = data.aws_lambda_function.rotation_function[0].arn
  rotate_immediately  = var.rotate_immediately
  rotation_rules {
    automatically_after_days = var.password_rotation_period
    duration                 = var.rotation_duration
  }
  depends_on = [
    aws_secretsmanager_secret_version.atlas_cred_conn_rotated
  ]
}
