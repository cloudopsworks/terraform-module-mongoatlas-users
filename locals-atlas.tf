##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
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
    for ep in try(v.connection_strings.private_endpoint, []) : "${k}-${ep.endpoints[0].endpoint_id}" => {
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
      plain        = try(v.connection_strings.standard, "")
      plain_srv    = try(v.connection_strings.standard_srv, "")
      standard     = split("/", try(v.connection_strings.standard, ""))
      standard_srv = split("/", try(v.connection_strings.standard_srv, ""))
    }
  }
  user_passwords = {
    for k, v in var.users : k => (var.password_externally_managed ? random_password.randompass_external[k].result : random_password.randompass[k].result)
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
}
