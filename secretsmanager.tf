##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  mongodb_credentials = {
    for k, v in var.users : k => {
      username     = mongodbatlas_database_user.this[k].username
      password     = random_password.randompass[k].result
      project_name = var.project_name != "" ? var.project_name : data.mongodbatlas_project.this_id[0].name
      project_id   = var.project_id != "" ? var.project_id : data.mongodbatlas_project.this[0].id
      engine       = "mongodbatlas"
    }
  }
}

# Secrets saving
resource "aws_secretsmanager_secret" "dbuser" {
  for_each = local.mongodb_credentials
  name     = "${local.secret_store_path}/mongodbatlas/${each.value.project_name}/${each.key}"
  tags     = local.all_tags
}

resource "aws_secretsmanager_secret_version" "dbuser" {
  for_each      = local.mongodb_credentials
  secret_id     = aws_secretsmanager_secret.dbuser[each.key].id
  secret_string = mongodbatlas_database_user.this[each.key].username
}

resource "aws_secretsmanager_secret" "randompass" {
  for_each = local.mongodb_credentials
  name     = "${local.secret_store_path}/mongodbatlas/${each.value.project_name}/${each.key}-password"
  tags     = local.all_tags
}

resource "aws_secretsmanager_secret_version" "randompass" {
  for_each      = local.mongodb_credentials
  secret_id     = aws_secretsmanager_secret.randompass[each.key].id
  secret_string = random_password.randompass[each.key].result
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
  secret_string = jsonencode(local.mongodb_credentials[each.key])
}
