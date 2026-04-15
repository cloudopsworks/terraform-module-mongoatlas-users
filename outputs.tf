##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

output "credentials" {
  description = "Sensitive map of MongoDB Atlas user credentials including passwords and connection strings. Pass to cloud-specific modules for secret store storage."
  sensitive   = true
  value       = local.mongodb_credentials
}

output "users" {
  description = "Non-sensitive user metadata map keyed by user key."
  value = {
    for k, v in local.mongodb_credentials : k => {
      username     = nonsensitive(v.username)
      project_name = nonsensitive(v.project_name)
      project_id   = nonsensitive(v.project_id)
      engine       = nonsensitive(v.engine)
    }
  }
}

output "hoop_output" {
  description = "Hoop.dev connection metadata without cloud-specific secret references. Consumed by cloud-specific wrapper modules which enrich it with their secret store references before passing to terraform-module-hoop-connection."
  value = try(var.hoop.enabled, false) && try(var.hoop.agent_id, "") != "" ? {
    agent_id = var.hoop.agent_id
    connections = {
      for key, user in var.users : key => {
        name  = local.connection_names[key]
        type  = "database"
        subtype = "mongodb"
        tags  = try(var.hoop.tags, {})
        access_control = setunion(
          toset(try(var.hoop.access_control, [])),
          toset(try(user.hoop.access_control, []))
        )
        access_modes = {
          connect  = "enabled"
          exec     = "enabled"
          runbooks = "enabled"
          schema   = "enabled"
        }
        import               = try(user.hoop.import, false)
        use_private_endpoint = try(user.connection_strings.endpoint_id, "") != ""
      }
    }
  } : null
}
