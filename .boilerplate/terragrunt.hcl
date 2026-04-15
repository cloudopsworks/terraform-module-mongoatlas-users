locals {
  local_vars  = yamldecode(file("./inputs.yaml"))
  spoke_vars  = yamldecode(file(find_in_parent_folders("spoke-inputs.yaml")))
  region_vars = yamldecode(file(find_in_parent_folders("region-inputs.yaml")))
  env_vars    = yamldecode(file(find_in_parent_folders("env-inputs.yaml")))
  global_vars = yamldecode(file(find_in_parent_folders("global-inputs.yaml")))

  local_tags  = jsondecode(file("./local-tags.json"))
  spoke_tags  = jsondecode(file(find_in_parent_folders("spoke-tags.json")))
  region_tags = jsondecode(file(find_in_parent_folders("region-tags.json")))
  env_tags    = jsondecode(file(find_in_parent_folders("env-tags.json")))
  global_tags = jsondecode(file(find_in_parent_folders("global-tags.json")))

  tags = merge(
    local.global_tags,
    local.env_tags,
    local.region_tags,
    local.spoke_tags,
    local.local_tags
  )
}

include "root" {
  path = find_in_parent_folders("{{ .RootFileName }}")
}

generate "provider-mongoatlas" {
  path      = "provider-mongoatlas.g.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "mongodbatlas" {
  assume_role {
    role_arn     = "${local.global_vars.mongodb_atlas.secrets.sts_role_arn}"
  }
  aws_access_key_id     = "${get_env("AWS_ACCESS_KEY_ID", "")}"
  aws_secret_access_key = "${get_env("AWS_SECRET_ACCESS_KEY", "")}"
  aws_session_token     = "${get_env("AWS_SESSION_TOKEN", "")}"
  secret_name           = "${local.global_vars.mongodb_atlas.secrets.name}"
  region                = "${local.global_vars.mongodb_atlas.secrets.region}"
  sts_endpoint          = "${local.global_vars.mongodb_atlas.secrets.sts_endpoint}"
}
EOF
}
{{ if .project }}
dependency "project" {
  config_path = "{{ .project_path }}"
  mock_outputs_allowed_terraform_commands = ["validate", "destroy"]
  mock_outputs = {
    project_id = "8403958hjhhhtur"
  }
}
{{ end }}
terraform {
  source = "{{ .sourceUrl }}"
}

inputs = {
  is_hub     = {{ .is_hub }}
  org        = local.env_vars.org
  spoke_def  = local.spoke_vars.spoke
  {{- range .requiredVariables }}
  {{- if ne .Name "org" }}
  {{ .Name }} = local.local_vars.{{ .Name }}
  {{- end }}
  {{- end }}
  {{- range .optionalVariables }}
  {{- if not (eq .Name "extra_tags" "is_hub" "spoke_def" "org" "settings") }}
  {{- if and $.project (eq .Name "project_id") }}
  {{ .Name }} = dependency.project.outputs.project_id
  {{- else }}
  {{ .Name }} = try(local.local_vars.{{ .Name }}, {{ .DefaultValue }})
  {{- end }}
  {{- end }}
  {{- end }}
  extra_tags = local.tags
}