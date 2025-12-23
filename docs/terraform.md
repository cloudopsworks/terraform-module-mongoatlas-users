## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.4 |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | ~> 2.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.4 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.27.0 |
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | 2.3.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.13.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | cloudopsworks/tags/local | 1.0.9 |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.atlas_cred_conn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_rotation.atlas_cred_conn_rotation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
| [aws_secretsmanager_secret_version.atlas_cred_conn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.atlas_cred_conn_rotated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [mongodbatlas_database_user.this](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user) | resource |
| [null_resource.hoop_connection](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.randompass](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.randompass_rotated](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [time_rotating.randompass](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [aws_lambda_function.rotation_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lambda_function) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_secretsmanager_secret_version.atlas_cred_conn_rotated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_versions.atlas_cred_conn_rotated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_versions) | data source |
| [aws_secretsmanager_secrets.atlas_cred_conn_rotated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secrets) | data source |
| [mongodbatlas_advanced_cluster.cluster](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/advanced_cluster) | data source |
| [mongodbatlas_project.this](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/project) | data source |
| [mongodbatlas_project.this_id](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | extra\_tags: {} # (Optional) Extra tags to apply to all resources. Default: {}. | `map(string)` | `{}` | no |
| <a name="input_force_reset"></a> [force\_reset](#input\_force\_reset) | force\_reset: false # (Optional) Force Reset the password. Default: false. | `bool` | `false` | no |
| <a name="input_hoop"></a> [hoop](#input\_hoop) | hoop:<br/>  enabled: false # (Optional) Whether to enable Hoop.dev connection. Default: false.<br/>  agent: "my-agent" # (Required if enabled) Hoop.dev agent name.<br/>  tags: # (Optional) List of tags for the Hoop connection.<br/>    - "tag1" | `any` | `{}` | no |
| <a name="input_is_hub"></a> [is\_hub](#input\_is\_hub) | is\_hub: false # (Optional) Whether this is a hub or spoke configuration. Default: false. | `bool` | `false` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | name\_prefix: "atlas" # (Required) A prefix for the name of the cluster, used when username is not provided. | `string` | n/a | yes |
| <a name="input_org"></a> [org](#input\_org) | org:<br/>  organization\_name: "my-org" # (Required) Organization name.<br/>  organization\_unit: "my-unit" # (Required) Organization unit.<br/>  environment\_type: "prod" # (Required) Environment type.<br/>  environment\_name: "production" # (Required) Environment name. | <pre>object({<br/>    organization_name = string<br/>    organization_unit = string<br/>    environment_type  = string<br/>    environment_name  = string<br/>  })</pre> | n/a | yes |
| <a name="input_password_rotation_period"></a> [password\_rotation\_period](#input\_password\_rotation\_period) | password\_rotation\_period: 90 # (Optional) Password rotation period in days. Default: 90. | `number` | `90` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | project\_id: "60f0f0f0f0f0f0f0f0f0f0f0" # (Optional) The ID of the project where the cluster will be created. Default: "". | `string` | `""` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | project\_name: "my-project" # (Optional) The name of the project where the cluster will be created. Default: "". | `string` | `""` | no |
| <a name="input_rotate_immediately"></a> [rotate\_immediately](#input\_rotate\_immediately) | rotate\_immediately: false # (Optional) Rotate the password immediately. Default: false. | `bool` | `false` | no |
| <a name="input_rotation_duration"></a> [rotation\_duration](#input\_rotation\_duration) | rotation\_duration: "1h" # (Optional) Duration of the lambda function to rotate the password. Default: "1h". | `string` | `"1h"` | no |
| <a name="input_rotation_lambda_name"></a> [rotation\_lambda\_name](#input\_rotation\_lambda\_name) | rotation\_lambda\_name: "" # (Optional) Name of the lambda function to rotate the password. Default: "". | `string` | `""` | no |
| <a name="input_run_hoop"></a> [run\_hoop](#input\_run\_hoop) | run\_hoop: false # (Optional) Run hoop with agent, be careful with this option, it will run the HOOP command in output in a null\_resource. Default: false. | `bool` | `false` | no |
| <a name="input_secrets_kms_key_id"></a> [secrets\_kms\_key\_id](#input\_secrets\_kms\_key\_id) | secrets\_kms\_key\_id: "alias/aws/secretsmanager" # (Optional) KMS Key ID to use to encrypt data in this secret, can be ARN or KMS Alias. Default: null. | `string` | `null` | no |
| <a name="input_spoke_def"></a> [spoke\_def](#input\_spoke\_def) | spoke\_def: "001" # (Optional) Spoke definition. Default: "001". | `string` | `"001"` | no |
| <a name="input_users"></a> [users](#input\_users) | users:<br/>  user1:<br/>    username: "user1"  # (Optional) Uses this value for the name of the user. Default: generated using name\_prefix and system names.<br/>    name\_prefix: "prefix1" # (Optional) If omitted var.name\_prefix is used.<br/>    auth\_database: "admin" # (Optional) The database against which the user authenticates. Default: "admin".<br/>    password\_rotation\_period: 90 # (Optional) Password rotation period in days for this specific user. Default: var.password\_rotation\_period.<br/>    roles: # (Required) List of roles for the user.<br/>      - role\_name: "readWrite" # (Required) Name of the role. Possible values: readWrite, read, dbAdmin, etc.<br/>        database\_name: "test" # (Required) Database to which the role applies.<br/>        collection\_name: "test" # (Optional) Collection to which the role applies.<br/>    scopes: # (Optional) List of scopes for the user.<br/>      - name: "cluster-name" # (Required) Name of the cluster or data lake.<br/>        type: "CLUSTER" # (Optional) Type of the scope. Possible values: CLUSTER, DATA\_LAKE. Default: "CLUSTER".<br/>    connection\_strings: # (Optional) Connection strings settings for the user.<br/>      enabled: false # (Optional) Whether to enable connection strings in secrets. Default: false.<br/>      cluster: "test" # (Required if enabled) Name of the cluster.<br/>      endpoint\_id: "vpce-xxxxxyyyzzz" # (Optional) Private endpoint ID.<br/>      database\_name: "mydatabase" # (Optional) Database name for the connection string. | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hoop_connection"></a> [hoop\_connection](#output\_hoop\_connection) | n/a |
| <a name="output_users"></a> [users](#output\_users) | n/a |
