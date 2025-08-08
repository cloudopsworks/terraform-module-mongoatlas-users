##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
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
      username                      = mongodbatlas_database_user.this[k].username
      password                      = local.user_passwords[k]
      project_name                  = var.project_name != "" ? var.project_name : data.mongodbatlas_project.this_id[0].name
      project_id                    = var.project_id != "" ? var.project_id : data.mongodbatlas_project.this[0].id
      engine                        = "mongodbatlas"
      dbname                        = try(v.connection_strings.database_name, "")
      url                           = local.connection_strings_arrs[v.connection_strings.cluster].plain
      url_srv                       = local.connection_strings_arrs[v.connection_strings.cluster].plain_srv
      private_url                   = try(local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].connection, "")
      private_url_srv               = try(local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].srv_connection, "")
      connection_string             = length(local.connection_strings_arrs[v.connection_strings.cluster].standard) > 1 ? format("%s//%s:%s@%s/%s%s", local.connection_strings_arrs[v.connection_strings.cluster].standard[0], mongodbatlas_database_user.this[k].username, local.user_passwords[k], local.connection_strings_arrs[v.connection_strings.cluster].standard[2], try(v.connection_strings.database_name, ""), local.connection_strings_arrs[v.connection_strings.cluster].standard[3]) : ""
      connection_string_srv         = length(local.connection_strings_arrs[v.connection_strings.cluster].standard_srv) > 1 ? format("%s//%s:%s@%s/%s%s", local.connection_strings_arrs[v.connection_strings.cluster].standard_srv[0], mongodbatlas_database_user.this[k].username, local.user_passwords[k], local.connection_strings_arrs[v.connection_strings.cluster].standard_srv[2], try(v.connection_strings.database_name, ""), local.connection_strings_arrs[v.connection_strings.cluster].standard[3]) : ""
      private_connection_string     = length(try(local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt, [])) > 1 ? format("%s//%s:%s@%s/%s%s", local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt[0], mongodbatlas_database_user.this[k].username, local.user_passwords[k], local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt[2], try(v.connection_strings.database_name, ""), local.connection_strings_arrs[v.connection_strings.cluster].standard[3]) : ""
      private_connection_string_srv = length(try(local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt_srv, [])) > 1 ? format("%s//%s:%s@%s/%s%s", local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt_srv[0], mongodbatlas_database_user.this[k].username, local.user_passwords[k], local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt_srv[2], try(v.connection_strings.database_name, ""), local.connection_strings_arrs[v.connection_strings.cluster].standard[3]) : ""
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
      username      = mongodbatlas_database_user.this[k].username
      password      = local.user_passwords[k]
      auth_database = try(v.auth_database, "admin")
      project_name  = var.project_name != "" ? var.project_name : data.mongodbatlas_project.this_id[0].name
      project_id    = var.project_id != "" ? var.project_id : data.mongodbatlas_project.this[0].id
      engine        = "mongodbatlas"
    } if !try(v.connection_strings.enabled, false)
  }

  mongodb_credentials = merge(local.mongodb_credentials_conn, local.mongodb_credentials_noconn)
  name_list = {
    for k, v in local.mongodb_credentials : k => format("%s/mongodbatlas/%s/%s-connstrings",
      local.secret_store_path,
      lower(replace(replace(v.project_name, " ", ""), "_", "-")),
      lower(replace(k, "_", "-")),
    )
  }
}

# Secrets saving
resource "aws_secretsmanager_secret" "atlas_cred_conn" {
  for_each    = local.mongodb_credentials
  description = "MongoDB User Credentials - ${each.value.username} - ${each.value.project_name}${try(each.value.dbname, "") != "" ? format(" - %s", each.value.dbname) : ""}"
  name        = local.name_list[each.key]
  kms_key_id  = var.secrets_kms_key_id
  tags = merge(local.all_tags, {
    "mongodb-username" = each.value.username
    "mongodb-project"  = each.value.project_name
    },
    try(each.value.dbname, "") != "" ? { "mongodb-dbname" = try(each.value.dbname, "") } : {}
  )
}

resource "aws_secretsmanager_secret_version" "atlas_cred_conn" {
  for_each = {
    for k, v in local.mongodb_credentials : k => v if var.rotation_lambda_name == ""
  }
  secret_id     = aws_secretsmanager_secret.atlas_cred_conn[each.key].id
  secret_string = jsonencode(each.value)
}

## Rotation Enabled
data "aws_secretsmanager_secrets" "atlas_cred_conn_rotated" {
  for_each = {
    for k, v in local.mongodb_credentials : k => v if var.rotation_lambda_name != ""
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
  for k, v in local.mongodb_credentials : k => v if var.rotation_lambda_name != "" && length(try(data.aws_secretsmanager_secrets.atlas_cred_conn_rotated[k].names, [])) > 0 }
  secret_id          = local.name_list[each.key]
  include_deprecated = true
}

data "aws_secretsmanager_secret_version" "atlas_cred_conn_rotated" {
  for_each = {
    for k, v in local.mongodb_credentials : k => v if var.rotation_lambda_name != "" && length(try(data.aws_secretsmanager_secrets.atlas_cred_conn_rotated[k].names, [])) > 0 && length(try(data.aws_secretsmanager_secret_versions.atlas_cred_conn_rotated[k].versions, [])) > 0
  }
  secret_id = local.name_list[each.key]
}

data "aws_lambda_function" "rotation_function" {
  count         = var.rotation_lambda_name != "" ? 1 : 0
  function_name = var.rotation_lambda_name
}

resource "aws_secretsmanager_secret_version" "atlas_cred_conn_rotated" {
  for_each = {
    for k, v in local.mongodb_credentials : k => v if var.rotation_lambda_name != ""
  }
  secret_id     = aws_secretsmanager_secret.atlas_cred_conn[each.key].id
  secret_string = jsonencode(each.value)
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}

resource "aws_secretsmanager_secret_rotation" "atlas_cred_conn_rotation" {
  for_each = {
    for k, v in local.mongodb_credentials : k => v if var.rotation_lambda_name != ""
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
