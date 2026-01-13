# Amazon ECS Express Service Module

Configuration in this directory creates an Amazon ECS Express Service and associated resources.

## Usage

```hcl
module "ecs_express_service" {
  source = "terraform-aws-modules/ecs/aws//modules/express-service"

  name = local.name

  cpu    = 1024
  memory = 4096

  network_configuration = {
    subnets = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  }

  primary_container = {
    container_port = 3000
    image          = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
  }

  scaling_target = {
    auto_scaling_metric       = "AVERAGE_CPU"
    auto_scaling_target_value = "80"
    max_task_count            = 3
    min_task_count            = 1
  }

  # Security Group
  vpc_id = module.vpc.vpc_id
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Examples

- [ECS cluster w/ integrated service(s)](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/complete)
- [ECS container definition](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/container-definition)
- [ECS cluster w/ EC2 Autoscaling capacity provider](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/ec2-autoscaling)
- [ECS express service](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/express-service)
- [ECS cluster w/ Fargate capacity provider](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/fargate)
- [ECS cluster w/ ECS managed instances capacity provider](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/managed-instances)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.28 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_express_gateway_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_express_gateway_service) | resource |
| [aws_iam_policy.execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.infrastructure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.execution_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.infrastructure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_iam_policy_document.execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.execution_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.infrastructure_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_log_group_class"></a> [cloudwatch\_log\_group\_class](#input\_cloudwatch\_log\_group\_class) | Specified the log class of the log group. Possible values are: `STANDARD` or `INFREQUENT_ACCESS` | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch\_log\_group\_kms\_key\_id](#input\_cloudwatch\_log\_group\_kms\_key\_id) | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Custom name of CloudWatch Log Group for ECS cluster | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events | `number` | `14` | no |
| <a name="input_cloudwatch_log_group_tags"></a> [cloudwatch\_log\_group\_tags](#input\_cloudwatch\_log\_group\_tags) | A map of additional tags to add to the log group created | `map(string)` | `{}` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Name or ARN of the ECS cluster. Defaults to `default` | `string` | `null` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Number of CPU units used by the task. Valid values are powers of `2` between `256` and `4096` | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether resources will be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled | `bool` | `true` | no |
| <a name="input_create_execution_iam_role"></a> [create\_execution\_iam\_role](#input\_create\_execution\_iam\_role) | Determines whether the ECS task definition IAM role should be created | `bool` | `true` | no |
| <a name="input_create_execution_policy"></a> [create\_execution\_policy](#input\_create\_execution\_policy) | Determines whether the ECS task definition IAM policy should be created. This includes permissions included in AmazonECSTaskExecutionRolePolicy as well as access to secrets and SSM parameters | `bool` | `true` | no |
| <a name="input_create_infrastructure_iam_role"></a> [create\_infrastructure\_iam\_role](#input\_create\_infrastructure\_iam\_role) | Determines whether the ECS infrastructure IAM role should be created | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Determines if a security group is created | `bool` | `true` | no |
| <a name="input_create_task_iam_role"></a> [create\_task\_iam\_role](#input\_create\_task\_iam\_role) | Determines whether the ECS task IAM role should be created | `bool` | `true` | no |
| <a name="input_execution_iam_policy_path"></a> [execution\_iam\_policy\_path](#input\_execution\_iam\_policy\_path) | Path for the iam role | `string` | `null` | no |
| <a name="input_execution_iam_role_arn"></a> [execution\_iam\_role\_arn](#input\_execution\_iam\_role\_arn) | Existing IAM role ARN | `string` | `null` | no |
| <a name="input_execution_iam_role_description"></a> [execution\_iam\_role\_description](#input\_execution\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_execution_iam_role_max_session_duration"></a> [execution\_iam\_role\_max\_session\_duration](#input\_execution\_iam\_role\_max\_session\_duration) | Maximum session duration (in seconds) for ECS task execution role. Default is 3600. | `number` | `null` | no |
| <a name="input_execution_iam_role_name"></a> [execution\_iam\_role\_name](#input\_execution\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_execution_iam_role_path"></a> [execution\_iam\_role\_path](#input\_execution\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_execution_iam_role_permissions_boundary"></a> [execution\_iam\_role\_permissions\_boundary](#input\_execution\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_execution_iam_role_policies"></a> [execution\_iam\_role\_policies](#input\_execution\_iam\_role\_policies) | Map of IAM role policy ARNs to attach to the IAM role | `map(string)` | `{}` | no |
| <a name="input_execution_iam_role_tags"></a> [execution\_iam\_role\_tags](#input\_execution\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_execution_iam_role_use_name_prefix"></a> [execution\_iam\_role\_use\_name\_prefix](#input\_execution\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`execution_iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_execution_iam_statements"></a> [execution\_iam\_statements](#input\_execution\_iam\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | <pre>map(object({<br/>    sid           = optional(string)<br/>    actions       = optional(list(string))<br/>    not_actions   = optional(list(string))<br/>    effect        = optional(string)<br/>    resources     = optional(list(string))<br/>    not_resources = optional(list(string))<br/>    principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    not_principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    condition = optional(list(object({<br/>      test     = string<br/>      values   = list(string)<br/>      variable = string<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_execution_secret_arns"></a> [execution\_secret\_arns](#input\_execution\_secret\_arns) | List of SecretsManager secret ARNs the task execution role will be permitted to get/read | `list(string)` | `[]` | no |
| <a name="input_execution_ssm_param_arns"></a> [execution\_ssm\_param\_arns](#input\_execution\_ssm\_param\_arns) | List of SSM parameter ARNs the task execution role will be permitted to get/read | `list(string)` | `[]` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Path for health check requests. Defaults to `/ping` | `string` | `null` | no |
| <a name="input_infrastructure_iam_role_arn"></a> [infrastructure\_iam\_role\_arn](#input\_infrastructure\_iam\_role\_arn) | Existing IAM role ARN | `string` | `null` | no |
| <a name="input_infrastructure_iam_role_description"></a> [infrastructure\_iam\_role\_description](#input\_infrastructure\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_infrastructure_iam_role_name"></a> [infrastructure\_iam\_role\_name](#input\_infrastructure\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_infrastructure_iam_role_path"></a> [infrastructure\_iam\_role\_path](#input\_infrastructure\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_infrastructure_iam_role_permissions_boundary"></a> [infrastructure\_iam\_role\_permissions\_boundary](#input\_infrastructure\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_infrastructure_iam_role_tags"></a> [infrastructure\_iam\_role\_tags](#input\_infrastructure\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_infrastructure_iam_role_use_name_prefix"></a> [infrastructure\_iam\_role\_use\_name\_prefix](#input\_infrastructure\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount of memory (in MiB) used by the task. Valid values are between `512` and `8192` | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the service. If not specified, a name will be generated. Changing this forces a new resource to be created | `string` | `""` | no |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | The network configuration for task in this service revision | <pre>object({<br/>    security_groups = optional(list(string), [])<br/>    subnets         = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_primary_container"></a> [primary\_container](#input\_primary\_container) | The primary container configuration for this service revision | <pre>object({<br/>    aws_logs_configuration = optional(object({<br/>      log_group         = string<br/>      log_stream_prefix = string<br/>    }))<br/>    command        = optional(list(string))<br/>    container_port = optional(number)<br/>    environment = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })))<br/>    image = string<br/>    repository_credentials = optional(object({<br/>      credentials_parameter = string<br/>    }))<br/>    secret = optional(list(object({<br/>      name       = string<br/>      value_from = string<br/>    })))<br/>  })</pre> | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_scaling_target"></a> [scaling\_target](#input\_scaling\_target) | The auto-scaling configuration for this service revision | <pre>object({<br/>    auto_scaling_metric       = string<br/>    auto_scaling_target_value = number<br/>    max_task_count            = number<br/>    min_task_count            = number<br/>  })</pre> | `null` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description of the security group created | `string` | `null` | no |
| <a name="input_security_group_egress_rules"></a> [security\_group\_egress\_rules](#input\_security\_group\_egress\_rules) | Security group egress rules to add to the security group created | <pre>map(object({<br/>    name = optional(string)<br/><br/>    cidr_ipv4                    = optional(string)<br/>    cidr_ipv6                    = optional(string)<br/>    description                  = optional(string)<br/>    from_port                    = optional(string)<br/>    ip_protocol                  = optional(string, "tcp")<br/>    prefix_list_id               = optional(string)<br/>    referenced_security_group_id = optional(string)<br/>    tags                         = optional(map(string), {})<br/>    to_port                      = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_security_group_ingress_rules"></a> [security\_group\_ingress\_rules](#input\_security\_group\_ingress\_rules) | Security group ingress rules to add to the security group created | <pre>map(object({<br/>    name = optional(string)<br/><br/>    cidr_ipv4                    = optional(string)<br/>    cidr_ipv6                    = optional(string)<br/>    description                  = optional(string)<br/>    from_port                    = optional(string)<br/>    ip_protocol                  = optional(string, "tcp")<br/>    prefix_list_id               = optional(string)<br/>    referenced_security_group_id = optional(string)<br/>    tags                         = optional(map(string), {})<br/>    to_port                      = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name to use on security group created | `string` | `null` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | A map of additional tags to add to the security group created | `map(string)` | `{}` | no |
| <a name="input_security_group_use_name_prefix"></a> [security\_group\_use\_name\_prefix](#input\_security\_group\_use\_name\_prefix) | Determines whether the security group name (`security_group_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_task_iam_role_arn"></a> [task\_iam\_role\_arn](#input\_task\_iam\_role\_arn) | Existing IAM role ARN | `string` | `null` | no |
| <a name="input_task_iam_role_description"></a> [task\_iam\_role\_description](#input\_task\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_task_iam_role_max_session_duration"></a> [task\_iam\_role\_max\_session\_duration](#input\_task\_iam\_role\_max\_session\_duration) | Maximum session duration (in seconds) for ECS task role. Default is 3600. | `number` | `null` | no |
| <a name="input_task_iam_role_name"></a> [task\_iam\_role\_name](#input\_task\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_task_iam_role_path"></a> [task\_iam\_role\_path](#input\_task\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_task_iam_role_permissions_boundary"></a> [task\_iam\_role\_permissions\_boundary](#input\_task\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_task_iam_role_policies"></a> [task\_iam\_role\_policies](#input\_task\_iam\_role\_policies) | Map of additioanl IAM role policy ARNs to attach to the IAM role | `map(string)` | `{}` | no |
| <a name="input_task_iam_role_statements"></a> [task\_iam\_role\_statements](#input\_task\_iam\_role\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | <pre>map(object({<br/>    sid           = optional(string)<br/>    actions       = optional(list(string))<br/>    not_actions   = optional(list(string))<br/>    effect        = optional(string)<br/>    resources     = optional(list(string))<br/>    not_resources = optional(list(string))<br/>    principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    not_principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    condition = optional(list(object({<br/>      test     = string<br/>      values   = list(string)<br/>      variable = string<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_task_iam_role_tags"></a> [task\_iam\_role\_tags](#input\_task\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_task_iam_role_use_name_prefix"></a> [task\_iam\_role\_use\_name\_prefix](#input\_task\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`task_iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the security group will be created | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of CloudWatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of CloudWatch log group created |
| <a name="output_current_deployment"></a> [current\_deployment](#output\_current\_deployment) | Details about the current deployment |
| <a name="output_execution_iam_role_arn"></a> [execution\_iam\_role\_arn](#output\_execution\_iam\_role\_arn) | Task execution IAM role ARN |
| <a name="output_execution_iam_role_name"></a> [execution\_iam\_role\_name](#output\_execution\_iam\_role\_name) | Task execution IAM role name |
| <a name="output_infrastructure_iam_role_arn"></a> [infrastructure\_iam\_role\_arn](#output\_infrastructure\_iam\_role\_arn) | Infrastructure IAM role ARN |
| <a name="output_infrastructure_iam_role_name"></a> [infrastructure\_iam\_role\_name](#output\_infrastructure\_iam\_role\_name) | Infrastructure IAM role name |
| <a name="output_ingress_paths"></a> [ingress\_paths](#output\_ingress\_paths) | List of ingress paths associated with the service |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Amazon Resource Name (ARN) of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
| <a name="output_service_arn"></a> [service\_arn](#output\_service\_arn) | ARN of the ECS Express Service |
| <a name="output_service_revision_arn"></a> [service\_revision\_arn](#output\_service\_revision\_arn) | ARN of the ECS Express Service revision |
| <a name="output_service_url"></a> [service\_url](#output\_service\_url) | URL of the ECS Express Service |
| <a name="output_task_iam_role_arn"></a> [task\_iam\_role\_arn](#output\_task\_iam\_role\_arn) | Task IAM role ARN |
| <a name="output_task_iam_role_name"></a> [task\_iam\_role\_name](#output\_task\_iam\_role\_name) | Task IAM role name |
<!-- END_TF_DOCS -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/LICENSE).
