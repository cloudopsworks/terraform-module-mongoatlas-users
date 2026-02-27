##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  hoop_tags = length(try(var.hoop.tags, {})) > 0 ? join(" ", [for k, v in var.hoop.tags : "--tags \"${k}=${v}\""]) : ""
  hoop_connection = try(var.hoop.enabled, false) && try(var.hoop.agent, "") != "" ? {
    for key, user in local.mongodb_credentials : key => nonsensitive(
      <<EOT
hoop admin create connection mongo-db-${lower(user.project_name)}-${lower(key)}-${lookup(local.default_roles, var.users[key].role_name, "default")} \
  --agent ${var.hoop.agent} \
  --type database/mongodb \
  -e "CONNECTION_STRING=_aws:${aws_secretsmanager_secret.atlas_cred_conn[key].name}:${try(user.endpoint_id, "") != "" ? "private_" : ""}connection_string" \
  --overwrite \
  ${local.hoop_tags}
EOT
    )
  } : {}
}

resource "null_resource" "hoop_connection" {
  for_each = {
    for k, v in local.hoop_connection : k => v
    if var.run_hoop
  }
  provisioner "local-exec" {
    command     = each.value
    interpreter = ["bash", "-c"]
  }
}

output "hoop_connection" {
  value = local.hoop_connection
}
