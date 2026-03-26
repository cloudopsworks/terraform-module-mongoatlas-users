##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  user_names_list = {
    for k, v in var.users : k => try(v.username, format("%s-%s-%s", try(v.name_prefix, var.name_prefix), local.system_name_short, k))
  }
}

data "mongodbatlas_project" "this" {
  count = var.project_name != "" ? 1 : 0
  name  = var.project_name
}

data "mongodbatlas_project" "this_id" {
  count      = var.project_id != "" ? 1 : 0
  project_id = var.project_id
}

# Try to import existing users if enabled and project_id or project_name is provided, otherwise create new users with random passwords
import {
  for_each = {
    for key, user in var.users : key => user if try(user.import, false)
  }
  to = mongodbatlas_database_user.this[each.key]
  id = format("%s/%s/%s", local.project_id, local.user_names_list[each.key], try(each.value.auth_database, "admin"))
}

resource "mongodbatlas_database_user" "this" {
  for_each           = var.users
  auth_database_name = try(each.value.auth_database, "admin")
  project_id         = local.project_id
  username           = local.user_names_list[each.key]
  password           = var.rotation_lambda_name == "" ? random_password.randompass[each.key].result : random_password.randompass_rotated[each.key].result

  dynamic "roles" {
    for_each = try(each.value.roles, [])
    content {
      role_name       = roles.value.role_name
      database_name   = roles.value.database_name
      collection_name = try(roles.value.collection_name, null)
    }
  }

  dynamic "scopes" {
    for_each = try(each.value.scopes, [])
    content {
      name = scopes.value.name
      type = try(scopes.value.type, "CLUSTER")
    }
  }

  dynamic "labels" {
    for_each = local.all_tags
    content {
      key   = labels.key
      value = replace(labels.value, "/[/$%&#]/", "+")
    }
  }
}

data "mongodbatlas_advanced_cluster" "cluster" {
  for_each = toset([
    for k, v in var.users : v.connection_strings.cluster
    if try(v.connection_strings.enabled, false)
  ])
  project_id = local.project_id
  name       = each.value
}