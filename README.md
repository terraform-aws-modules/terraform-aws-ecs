# AWS ECS Terraform module

Terraform module which creates ECS (Elastic Container Service) resources on AWS.

## Available Features

- ECS cluster
- Fargate capacity providers
- EC2 AutoScaling Group capacity providers

## Usage

### Fargate Capacity Providers

```hcl
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-fargate"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = {
    Environment = "Development"
    Project     = "EcsEc2"
  }
}
```

### EC2 Autoscaling Capacity Providers

```hcl
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-ec2"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  autoscaling_capacity_providers = {
    one = {
      auto_scaling_group_arn         = "arn:aws:autoscaling:eu-west-1:012345678901:autoScalingGroup:08419a61:autoScalingGroupName/ecs-ec2-one-20220603194933774300000011"
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 5
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 60
      }

      default_capacity_provider_strategy = {
        weight = 60
        base   = 20
      }
    }
    two = {
      auto_scaling_group_arn         = "arn:aws:autoscaling:eu-west-1:012345678901:autoScalingGroup:08419a61:autoScalingGroupName/ecs-ec2-two-20220603194933774300000022"
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 15
        minimum_scaling_step_size = 5
        status                    = "ENABLED"
        target_capacity           = 90
      }

      default_capacity_provider_strategy = {
        weight = 40
      }
    }
  }

  tags = {
    Environment = "Development"
    Project     = "EcsEc2"
  }
}
```

### Fargate & EC2 Autoscaling Capacity Providers

```hcl
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-mixed"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  autoscaling_capacity_providers = {
    one = {
      auto_scaling_group_arn         = "arn:aws:autoscaling:eu-west-1:012345678901:autoScalingGroup:08419a61:autoScalingGroupName/ecs-ec2-one-20220603194933774300000011"
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 5
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 60
      }

      default_capacity_provider_strategy = {
        weight = 60
        base   = 20
      }
    }
    two = {
      auto_scaling_group_arn         = "arn:aws:autoscaling:eu-west-1:012345678901:autoScalingGroup:08419a61:autoScalingGroupName/ecs-ec2-two-20220603194933774300000022"
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 15
        minimum_scaling_step_size = 5
        status                    = "ENABLED"
        target_capacity           = 90
      }

      default_capacity_provider_strategy = {
        weight = 40
      }
    }
  }

  tags = {
    Environment = "Development"
    Project     = "EcsEc2"
  }
}
```

## Conditional Creation

The following values are provided to toggle on/off creation of the associated resources as desired:

```hcl
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"

  # Disable creation of cluster and all resources
  create = false

  # ... omitted
}
```

## Examples

- [ECS Cluster w/ EC2 Autoscaling Capacity Provider](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/complete)
- [ECS Cluster w/ Fargate Capacity Provider](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/fargate)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.43 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.43 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_capacity_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_iam_role.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.task_exec_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.task_def](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.task_exec_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_exec_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaling_capacity_providers"></a> [autoscaling\_capacity\_providers](#input\_autoscaling\_capacity\_providers) | Map of autoscaling capacity provider definitons to create for the cluster | `any` | `{}` | no |
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch\_log\_group\_kms\_key\_id](#input\_cloudwatch\_log\_group\_kms\_key\_id) | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events. Default retention - 90 days | `number` | `90` | no |
| <a name="input_cluster_configuration"></a> [cluster\_configuration](#input\_cluster\_configuration) | The execute command configuration for the cluster | `any` | `{}` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster (up to 255 letters, numbers, hyphens, and underscores) | `string` | `""` | no |
| <a name="input_cluster_service_connect_defaults"></a> [cluster\_service\_connect\_defaults](#input\_cluster\_service\_connect\_defaults) | Configures a default Service Connect namespace | `map(string)` | `{}` | no |
| <a name="input_cluster_settings"></a> [cluster\_settings](#input\_cluster\_settings) | Configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster | `map(string)` | <pre>{<br>  "name": "containerInsights",<br>  "value": "enabled"<br>}</pre> | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether resources will be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled | `bool` | `true` | no |
| <a name="input_create_task_exec_iam_role"></a> [create\_task\_exec\_iam\_role](#input\_create\_task\_exec\_iam\_role) | Determines whether the ECS task definition IAM role should be created | `bool` | `false` | no |
| <a name="input_default_capacity_provider_use_fargate"></a> [default\_capacity\_provider\_use\_fargate](#input\_default\_capacity\_provider\_use\_fargate) | Determines whether to use Fargate or autoscaling for default capacity provider strategy | `bool` | `true` | no |
| <a name="input_fargate_capacity_providers"></a> [fargate\_capacity\_providers](#input\_fargate\_capacity\_providers) | Map of Fargate capacity provider definitions to use for the cluster | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_task_exec_iam_role_description"></a> [task\_exec\_iam\_role\_description](#input\_task\_exec\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_task_exec_iam_role_name"></a> [task\_exec\_iam\_role\_name](#input\_task\_exec\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_task_exec_iam_role_path"></a> [task\_exec\_iam\_role\_path](#input\_task\_exec\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_task_exec_iam_role_permissions_boundary"></a> [task\_exec\_iam\_role\_permissions\_boundary](#input\_task\_exec\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_task_exec_iam_role_policies"></a> [task\_exec\_iam\_role\_policies](#input\_task\_exec\_iam\_role\_policies) | Map of IAM role policy ARNs to attach to the IAM role | `map(string)` | `{}` | no |
| <a name="input_task_exec_iam_role_tags"></a> [task\_exec\_iam\_role\_tags](#input\_task\_exec\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_task_exec_iam_role_use_name_prefix"></a> [task\_exec\_iam\_role\_use\_name\_prefix](#input\_task\_exec\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`task_exec_iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_task_exec_secret_arns"></a> [task\_exec\_secret\_arns](#input\_task\_exec\_secret\_arns) | List of SecretsManager secret ARNs the task execution role will be permitted to get/read | `list(string)` | `[]` | no |
| <a name="input_task_exec_ssm_param_arns"></a> [task\_exec\_ssm\_param\_arns](#input\_task\_exec\_ssm\_param\_arns) | List of SSM parameter ARNs the task execution role will be permitted to get/read | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_capacity_providers"></a> [autoscaling\_capacity\_providers](#output\_autoscaling\_capacity\_providers) | Map of autoscaling capacity providers created and their attributes |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | Arn of cloudwatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of cloudwatch log group created |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN that identifies the cluster |
| <a name="output_cluster_capacity_providers"></a> [cluster\_capacity\_providers](#output\_cluster\_capacity\_providers) | Map of cluster capacity providers attributes |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID that identifies the cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name that identifies the cluster |
| <a name="output_task_exec_iam_role_arn"></a> [task\_exec\_iam\_role\_arn](#output\_task\_exec\_iam\_role\_arn) | Task execution IAM role ARN |
| <a name="output_task_exec_iam_role_name"></a> [task\_exec\_iam\_role\_name](#output\_task\_exec\_iam\_role\_name) | Task execution IAM role name |
| <a name="output_task_exec_iam_role_unique_id"></a> [task\_exec\_iam\_role\_unique\_id](#output\_task\_exec\_iam\_role\_unique\_id) | Stable and unique string identifying the task execution IAM role |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Anton Babenko](https://github.com/antonbabenko) with help from [these awesome contributors](https://github.com/terraform-aws-modules/terraform-aws-ecs/graphs/contributors).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/LICENSE) for full details.
