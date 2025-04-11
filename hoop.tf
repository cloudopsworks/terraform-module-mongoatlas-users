##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  hoop_tags = length(try(var.hoop.tags, [])) > 0 ? join(" ", [for v in var.hoop.tags : "--tags \"${v}\""]) : ""
  hoop_connection = try(var.hoop.enabled, false) ? [
    for key, user in local.mongodb_credentials : <<EOT
hoop admin create connection ${user.project_name}-${user.username}-${lookup(local.default_roles, user.role_name, "default")} \
  --agent ${var.hoop.agent} \
  --type database/mongodb \
  -e "CONNECTION_STRING=_aws:${aws_secretsmanager_secret.atlas_cred[0].name}:connection_string" \
  --overwrite \
  ${local.hoop_tags}
EOT
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
