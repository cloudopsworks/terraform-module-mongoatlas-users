## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | ~> 2.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.4 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | 2.3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.13.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | cloudopsworks/tags/local | 1.0.9 |

## Resources

| Name | Type |
|------|------|
| [mongodbatlas_database_user.this](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user) | resource |
| [random_password.randompass](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.randompass_external](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [time_rotating.randompass](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [mongodbatlas_advanced_cluster.cluster](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/advanced_cluster) | data source |
| [mongodbatlas_project.this](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/project) | data source |
| [mongodbatlas_project.this_id](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | extra\_tags: {} # (Optional) Extra tags to apply to all resources. Default: {}. | `map(string)` | `{}` | no |
| <a name="input_force_reset"></a> [force\_reset](#input\_force\_reset) | force\_reset: false # (Optional) Force-reset credentials even if unchanged (useful for break-glass scenarios). Default: false. | `bool` | `false` | no |
| <a name="input_hoop"></a> [hoop](#input\_hoop) | hoop:<br/>  enabled: false # (Optional) Enable Hoop.dev connection metadata output. Default: false.<br/>  agent\_id: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" # (Required if enabled) Hoop.dev agent ID (UUID) for hoop\_output generation. No default.<br/>  tags: # (Optional) Free-form tags to annotate the Hoop connection. Default: {}.<br/>    key: "value"<br/>  access\_control: [] # (Optional) Global access control list applied to all Hoop connections. Merged with per-user users[*].hoop.access\_control. Default: []. | `any` | `{}` | no |
| <a name="input_is_hub"></a> [is\_hub](#input\_is\_hub) | is\_hub: false # (Optional) Whether this is a hub or spoke configuration. Default: false. | `bool` | `false` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | name\_prefix: "atlas" # (Required) Prefix used to compose usernames when `users[<key>].username` is not provided. Allowed: lowercase letters, numbers, and hyphens. No default. | `string` | n/a | yes |
| <a name="input_org"></a> [org](#input\_org) | org:<br/>  organization\_name: "my-org" # (Required) Organization name.<br/>  organization\_unit: "my-unit" # (Required) Organization unit.<br/>  environment\_type: "prod" # (Required) Environment type.<br/>  environment\_name: "production" # (Required) Environment name. | <pre>object({<br/>    organization_name = string<br/>    organization_unit = string<br/>    environment_type  = string<br/>    environment_name  = string<br/>  })</pre> | n/a | yes |
| <a name="input_password_externally_managed"></a> [password\_externally\_managed](#input\_password\_externally\_managed) | password\_externally\_managed: false # (Optional) When true, the module sets an initial password but does not auto-rotate via time\_rotating. Use when an external system (e.g. AWS Lambda, GCP Cloud Function, Azure Function) manages password rotation. Default: false. | `bool` | `false` | no |
| <a name="input_password_rotation_period"></a> [password\_rotation\_period](#input\_password\_rotation\_period) | password\_rotation\_period: 90 # (Optional) Default rotation period in days for all users (overridden by `users[*].password_rotation_period`). Allowed: 1-365. Default: 90. | `number` | `90` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | project\_id: "60f0f0f0f0f0f0f0f0f0f0f0" # (Optional) Atlas Project ID. One of `project_id` or `project_name` must be provided. Default: "". | `string` | `""` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | project\_name: "my-project" # (Optional) Atlas Project Name. One of `project_id` or `project_name` must be provided. Default: "". | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | region: "us-east-1" # (Optional) Cloud provider region identifier used in system\_name\_short composition for username generation. Passed from cloud-specific wrapper modules. Default: "". | `string` | `""` | no |
| <a name="input_spoke_def"></a> [spoke\_def](#input\_spoke\_def) | spoke\_def: "001" # (Optional) Spoke definition. Default: "001". | `string` | `"001"` | no |
| <a name="input_users"></a> [users](#input\_users) | users:<br/>  <user\_key>:<br/>    username: "user1" # (Optional) Explicit username. If omitted, composed as `<name_prefix|user.name_prefix>-<system_name_short>-<user_key>`. Default: generated.<br/>    name\_prefix: "prefix1" # (Optional) Per-user prefix to build the username. If omitted, uses var.name\_prefix. Default: null.<br/>    auth\_database: "admin" # (Optional) Authentication database. Common: "admin". Default: "admin".<br/>    password\_rotation\_period: 90 # (Optional) Rotation period in days for this user. Overrides var.password\_rotation\_period. Default: var.password\_rotation\_period.<br/>    import: false # (Optional) When true, imports an existing MongoDB Atlas user instead of creating a new one. Default: false.<br/>    role\_name: "readwrite" # (Optional) Top-level primary role key used for Hoop connection naming. Allowed: readwrite, read, dbadmin, admin, dbowner, owner, clusteradmin. Default: "default".<br/>    roles: # (Required) MongoDB roles granted to this user.<br/>      - role\_name: "readWrite" # (Required) Built-in or custom role name. Common built-ins: read, readWrite, dbAdmin, dbOwner, userAdmin, clusterAdmin. No default.<br/>        database\_name: "test" # (Required) Database that the role applies to (e.g., "admin", "test", "app\_db"). No default.<br/>        collection\_name: "widgets" # (Optional) Collection the role is scoped to (if applicable). Default: null.<br/>    scopes: # (Optional) Atlas scope bindings for the user.<br/>      - name: "cluster-name" # (Required) Target cluster or data lake name. No default.<br/>        type: "CLUSTER" # (Optional) Scope type. Allowed: CLUSTER, DATA\_LAKE. Default: "CLUSTER".<br/>    connection\_strings: # (Optional) Control generation of connection strings in Secrets Manager.<br/>      enabled: false # (Optional) When true, include connection strings in credentials output. Default: false.<br/>      cluster: "cluster0" # (Required if enabled) Atlas Cluster name used to resolve connection strings. No default.<br/>      endpoint\_id: "vpce-0123456789abcdef" # (Optional) Private endpoint ID to build PrivateLink connection strings. Default: "".<br/>      database\_name: "mydatabase" # (Optional) Database name appended in the connection string. Default: "".<br/>    hoop: # (Optional) Per-user Hoop.dev integration overrides.<br/>      import: false # (Optional) When true, imports this user's existing Hoop connection instead of creating a new one. Default: false.<br/>      access\_control: [] # (Optional) Per-user access control list merged with global hoop.access\_control. Default: []. | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_credentials"></a> [credentials](#output\_credentials) | Sensitive map of MongoDB Atlas user credentials including passwords and connection strings. Pass to cloud-specific modules for secret store storage. |
| <a name="output_hoop_output"></a> [hoop\_output](#output\_hoop\_output) | Hoop.dev connection metadata without cloud-specific secret references. Consumed by cloud-specific wrapper modules which enrich it with their secret store references before passing to terraform-module-hoop-connection. |
| <a name="output_users"></a> [users](#output\_users) | Non-sensitive user metadata map keyed by user key. |
