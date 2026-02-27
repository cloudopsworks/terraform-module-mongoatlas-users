##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

module "hoop_connection" {
  for_each = {
    for key, role_user in local.mongodb_credentials : key => role_user
    if try(var.hoop.enabled, false) && try(var.hoop.agent_id, "") != ""
  }
  source = "./hoop"
  name = format("mongo-db-%s-%s-%s",
    lower(each.value.project_name),
    lower(each.key),
    lookup(local.default_roles, var.users[each.key].role_name, "default")
  )
  type     = "database"
  subtype  = "mongodb"
  agent_id = var.hoop.agent_id
  secrets = {
    "envvar:CONNECTION_STRING" = "_aws:${aws_secretsmanager_secret.atlas_cred_conn[key].name}:${try(user.endpoint_id, "") != "" ? "private_" : ""}connection_string"
  }
  access_modes = {
    connect  = "enabled"
    exec     = "enabled"
    runbooks = "enabled"
    schema   = "enabled"
  }
  tags           = var.hoop.tags
  access_control = setunion(toset(try(var.hoop.access_control, [])), toset(try(each.value.hoop.access_control, [])))
}
