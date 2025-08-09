## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.89 |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | ~> 1.32 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.4 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.89 |
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | ~> 1.32 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.2 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.4 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.13 |

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
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_force_reset"></a> [force\_reset](#input\_force\_reset) | (optional) Force Reset the password | `bool` | `false` | no |
| <a name="input_hoop"></a> [hoop](#input\_hoop) | (optional) Hoop Settings for the module | `any` | `{}` | no |
| <a name="input_is_hub"></a> [is\_hub](#input\_is\_hub) | Establish this is a HUB or spoke configuration | `bool` | `false` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (required) A prefix for the name of the cluster | `string` | n/a | yes |
| <a name="input_org"></a> [org](#input\_org) | n/a | <pre>object({<br/>    organization_name = string<br/>    organization_unit = string<br/>    environment_type  = string<br/>    environment_name  = string<br/>  })</pre> | n/a | yes |
| <a name="input_password_rotation_period"></a> [password\_rotation\_period](#input\_password\_rotation\_period) | (optional) Password rotation period in days | `number` | `90` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | (optional) The ID of the project where the cluster will be created | `string` | `""` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | (optional) The name of the project where the cluster will be created | `string` | `""` | no |
| <a name="input_rotate_immediately"></a> [rotate\_immediately](#input\_rotate\_immediately) | (optional) Rotate the password immediately | `bool` | `false` | no |
| <a name="input_rotation_duration"></a> [rotation\_duration](#input\_rotation\_duration) | (optional) Duration of the lambda function to rotate the password | `string` | `"1h"` | no |
| <a name="input_rotation_lambda_name"></a> [rotation\_lambda\_name](#input\_rotation\_lambda\_name) | (optional) Name of the lambda function to rotate the password | `string` | `""` | no |
| <a name="input_run_hoop"></a> [run\_hoop](#input\_run\_hoop) | Run hoop with agent, be careful with this option, it will run the HOOP command in output in a null\_resource | `bool` | `false` | no |
| <a name="input_secrets_kms_key_id"></a> [secrets\_kms\_key\_id](#input\_secrets\_kms\_key\_id) | (optional) KMS Key ID to use to encrypt data in this secret, can be ARN or KMS Alias | `string` | `null` | no |
| <a name="input_spoke_def"></a> [spoke\_def](#input\_spoke\_def) | n/a | `string` | `"001"` | no |
| <a name="input_users"></a> [users](#input\_users) | (required) Settings for the module | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hoop_connection"></a> [hoop\_connection](#output\_hoop\_connection) | n/a |
| <a name="output_users"></a> [users](#output\_users) | n/a |
