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
      secrets_credentials = nonsensitive(aws_secretsmanager_secret.atlas_cred_conn[k].name)
    }
  }
  sensitive = true
}