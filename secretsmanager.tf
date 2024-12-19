##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
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
  mongodb_credentials_conn = {
    for k, v in var.users : k => {
      username                      = mongodbatlas_database_user.this[k].username
      password                      = random_password.randompass[k].result
      project_name                  = var.project_name != "" ? var.project_name : data.mongodbatlas_project.this_id[0].name
      project_id                    = var.project_id != "" ? var.project_id : data.mongodbatlas_project.this[0].id
      engine                        = "mongodbatlas"
      connection_string             = local.connection_strings_arrs[v.connection_strings.cluster].plain
      connection_string_srv         = local.connection_strings_arrs[v.connection_strings.cluster].plain_srv
      private_connection_string     = try(local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].connection, "")
      private_connection_string_srv = try(local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].srv_connection, "")
    } if try(v.connection_strings.enabled, false)
  }
  mongodb_credentials_noconn = {
    for k, v in var.users : k => {
      username     = mongodbatlas_database_user.this[k].username
      password     = random_password.randompass[k].result
      project_name = var.project_name != "" ? var.project_name : data.mongodbatlas_project.this_id[0].name
      project_id   = var.project_id != "" ? var.project_id : data.mongodbatlas_project.this[0].id
      engine       = "mongodbatlas"
    } if !try(v.connection_strings.enabled, false)
  }
  mongodb_connection_strings = {
    for k, v in var.users : k => {
      username                      = mongodbatlas_database_user.this[k].username
      connection_string             = length(local.connection_strings_arrs[v.connection_strings.cluster].standard) > 1 ? format("%s//%s:%s@%s/%s%s", local.connection_strings_arrs[v.connection_strings.cluster].standard[0], mongodbatlas_database_user.this[k].username, random_password.randompass[k].result, local.connection_strings_arrs[v.connection_strings.cluster].standard[2], try(v.connection_strings.database_name, ""), local.connection_strings_arrs[v.connection_strings.cluster].standard[3]) : ""
      connection_string_srv         = length(local.connection_strings_arrs[v.connection_strings.cluster].standard_srv) > 1 ? format("%s//%s:%s@%s/%s%s", local.connection_strings_arrs[v.connection_strings.cluster].standard_srv[0], mongodbatlas_database_user.this[k].username, random_password.randompass[k].result, local.connection_strings_arrs[v.connection_strings.cluster].standard_srv[2], try(v.connection_strings.database_name, ""), local.connection_strings_arrs[v.connection_strings.cluster].standard[3]) : ""
      private_connection_string     = length(try(local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt, [])) > 1 ? format("%s//%s:%s@%s/%s%s", local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt[0], mongodbatlas_database_user.this[k].username, random_password.randompass[k].result, local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt[2], try(v.connection_strings.database_name, ""), local.connection_strings_arrs[v.connection_strings.cluster].standard[3]) : ""
      private_connection_string_srv = length(try(local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt_srv, [])) > 1 ? format("%s//%s:%s@%s/%s%s", local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt_srv[0], mongodbatlas_database_user.this[k].username, random_password.randompass[k].result, local.pvt_endpoints["${v.connection_strings.cluster}-${v.connection_strings.endpoint_id}"].pvt_srv[2], try(v.connection_strings.database_name, ""), local.connection_strings_arrs[v.connection_strings.cluster].standard[3]) : ""
    } if try(v.connection_strings.enabled, false)
  }

  mongodb_credentials = merge(local.mongodb_credentials_conn, local.mongodb_credentials_noconn)
}

# Secrets saving
resource "aws_secretsmanager_secret" "dbuser" {
  for_each = local.mongodb_credentials
  name     = "${local.secret_store_path}/mongodbatlas/${each.value.project_name}/${each.key}-username"
  tags     = local.all_tags
}

resource "aws_secretsmanager_secret_version" "dbuser" {
  for_each      = local.mongodb_credentials
  secret_id     = aws_secretsmanager_secret.dbuser[each.key].id
  secret_string = each.value.username
}

resource "aws_secretsmanager_secret" "randompass" {
  for_each = local.mongodb_credentials
  name     = "${local.secret_store_path}/mongodbatlas/${each.value.project_name}/${each.key}-password"
  tags     = local.all_tags
}

resource "aws_secretsmanager_secret_version" "randompass" {
  for_each      = local.mongodb_credentials
  secret_id     = aws_secretsmanager_secret.randompass[each.key].id
  secret_string = each.value.password
}

# Secrets saving
resource "aws_secretsmanager_secret" "atlas_cred" {
  for_each = local.mongodb_credentials
  name     = "${local.secret_store_path}/mongodbatlas/${each.value.project_name}/${each.key}-credentials"
  tags     = local.all_tags
}

resource "aws_secretsmanager_secret_version" "atlas_cred" {
  for_each      = local.mongodb_credentials
  secret_id     = aws_secretsmanager_secret.atlas_cred[each.key].id
  secret_string = jsonencode(each.value)
}

# Secrets saving
resource "aws_secretsmanager_secret" "atlas_cred_conn" {
  for_each = local.mongodb_credentials
  name     = "${local.secret_store_path}/mongodbatlas/${each.value.project_name}/${each.key}-connstrings"
  tags     = local.all_tags
}

resource "aws_secretsmanager_secret_version" "atlas_cred_conn" {
  for_each      = local.mongodb_connection_strings
  secret_id     = aws_secretsmanager_secret.atlas_cred_conn[each.key].id
  secret_string = jsonencode(each.value)
}
