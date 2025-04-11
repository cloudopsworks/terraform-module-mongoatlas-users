##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  hoop_tags = length(try(var.hoop.tags, [])) > 0 ? join(" ", [for v in var.hoop.tags : "--tags \"${v}\""]) : ""
  hoop_connection = try(var.hoop.enabled, false) ? [
    for key, user in local.mongodb_credentials : nonsensitive(
      <<EOT
hoop admin create connection ${lower(user.project_name)}-${lower(key)}-${lookup(local.default_roles, var.users[key].role_name, "default")} \
  --agent ${var.hoop.agent} \
  --type database/mongodb \
  -e "CONNECTION_STRING=_aws:${aws_secretsmanager_secret.atlas_cred_conn[key].name}:${try(user.endpoint_id, "") != "" ? "private_" : ""}connection_string" \
  --overwrite \
  ${local.hoop_tags}
EOT
    )
  ] : null
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
