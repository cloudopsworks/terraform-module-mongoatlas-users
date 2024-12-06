##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

output "users" {
  value = {
    for k, v in local.mongodb_credentials : k => {
      username            = v.username
      project_name        = v.project_name
      project_id          = v.project_id
      engine              = v.engine
      secrets_username    = aws_secretsmanager_secret.dbuser[k].name
      secrets_password    = aws_secretsmanager_secret.randompass[k].name
      secrets_credentials = aws_secretsmanager_secret.atlas_cred[k].name
    }
  }
}

output "debug" {
  value = data.mongodbatlas_advanced_cluster.cluster
}