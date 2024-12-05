##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

data "mongodbatlas_project" "this" {
  count = var.project_name != "" ? 1 : 0
  name  = var.project_name
}

data "mongodbatlas_project" "this_id" {
  count      = var.project_id != "" ? 1 : 0
  project_id = var.project_id
}


resource "mongodbatlas_database_user" "this" {
  for_each           = var.users
  auth_database_name = try(each.value.auth_database, "admin")
  project_id         = var.project_id != "" ? var.project_id : data.mongodbatlas_project.this[0].id
  username           = try(each.value.username, format("%s-%s-user", each.key, local.system_name_short, each.key))
  password           = random_password.randompass[each.key].result

  dynamic "roles" {
    for_each = try(each.value.roles, [])
    content {
      database_name = roles.value.database_name
      role_name     = roles.value.role_name
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