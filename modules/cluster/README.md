# Amazon ECS Cluster Terraform Module

Terraform module which creates Amazon ECS (Elastic Container Service) cluster resources on AWS.

## Available Features

- ECS cluster
- ECS managed instances capacity providers including necessary IAM roles, permissions, and security group
- Fargate capacity providers
- EC2 AutoScaling Group capacity providers
- ECS Service w/ task definition, task set, and container definition support

For more details see the [design doc](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/docs/README.md)

## Usage

### ECS Managed Instances Capacity Providers

```hcl
module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  name = "ecs-managed-instances"

  configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-managed-instances"
      }
    }
  }

  capacity_providers = {
    mi-example = {
      managed_instances_provider = {
        instance_launch_template = {
          instance_requirements = {
            instance_generations = ["current"]
            cpu_manufacturers    = ["intel", "amd"]

            memory_mib = {
              max = 8192
              min = 1024
            }

            vcpu_count = {
              max = 4
              min = 1
            }
          }

          network_configuration = {
            subnets = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
          }

          storage_configuration = {
            storage_size_gib = 30
          }
        }
      }
    }
  }

  # Managed instances security group
  vpc_id = "vpc-1234556abcdef"
  security_group_ingress_rules = {
    alb-http = {
      from_port                    = 4000
      description                  = "Service port"
      referenced_security_group_id = "sg-12345678"
    }
  }
  security_group_egress_rules = {
    all = {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "-1"
    }
  }

  tags = {
    Environment = "Development"
    Project     = "EcsEc2"
  }
}
```

### Fargate Capacity Providers

```hcl
module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  name = "ecs-fargate"

  configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  cluster_capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 20
    }
    FARGATE_SPOT = {
      weight = 50
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
module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  name = "ecs-ec2"

  configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  default_capacity_provider_strategy = {
    one = {
      weight = 60
      base   = 20
    }
    two = {
      weight = 40
    }
  }

  capacity_providers = {
    one = {
      auto_scaling_group_provider = {
        auto_scaling_group_arn         = "arn:aws:autoscaling:eu-west-1:012345678901:autoScalingGroup:08419a61:autoScalingGroupName/ecs-ec2-one-20220603194933774300000011"
        managed_draining               = "DISABLED"
        managed_termination_protection = "ENABLED"

        managed_scaling = {
          maximum_scaling_step_size = 5
          minimum_scaling_step_size = 1
          status                    = "ENABLED"
          target_capacity           = 60
        }
      }
    }
    two = {
      auto_scaling_group_provider = {
        auto_scaling_group_arn         = "arn:aws:autoscaling:eu-west-1:012345678901:autoScalingGroup:08419a61:autoScalingGroupName/ecs-ec2-two-20220603194933774300000022"
        managed_draining               = "ENABLED"
        managed_termination_protection = "ENABLED"

        managed_scaling = {
          maximum_scaling_step_size = 15
          minimum_scaling_step_size = 5
          status                    = "ENABLED"
          target_capacity           = 90
        }
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
module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  # Disable creation of cluster and all resources
  create = false

  # ... omitted
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
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.28 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.13 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_capacity_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.infrastructure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.infrastructure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.infrastructure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task_exec_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [time_sleep.this](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.infrastructure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.infrastructure_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.node_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_exec_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity_providers"></a> [capacity\_providers](#input\_capacity\_providers) | Map of capacity provider definitions to create | <pre>map(object({<br/>    auto_scaling_group_provider = optional(object({<br/>      auto_scaling_group_arn = string<br/>      managed_draining       = optional(string, "ENABLED")<br/>      managed_scaling = optional(object({<br/>        instance_warmup_period    = optional(number)<br/>        maximum_scaling_step_size = optional(number)<br/>        minimum_scaling_step_size = optional(number)<br/>        status                    = optional(string)<br/>        target_capacity           = optional(number)<br/>      }))<br/>      managed_termination_protection = optional(string)<br/>    }))<br/>    managed_instances_provider = optional(object({<br/>      infrastructure_role_arn = optional(string)<br/>      instance_launch_template = object({<br/>        capacity_option_type     = optional(string)<br/>        ec2_instance_profile_arn = optional(string)<br/>        instance_requirements = optional(object({<br/>          accelerator_count = optional(object({<br/>            max = optional(number)<br/>            min = optional(number)<br/>          }))<br/>          accelerator_manufacturers = optional(list(string))<br/>          accelerator_names         = optional(list(string))<br/>          accelerator_total_memory_mib = optional(object({<br/>            max = optional(number)<br/>            min = optional(number)<br/>          }))<br/>          accelerator_types      = optional(list(string))<br/>          allowed_instance_types = optional(list(string))<br/>          bare_metal             = optional(string)<br/>          baseline_ebs_bandwidth_mbps = optional(object({<br/>            max = optional(number)<br/>            min = optional(number)<br/>          }))<br/>          burstable_performance                                   = optional(string)<br/>          cpu_manufacturers                                       = optional(list(string))<br/>          excluded_instance_types                                 = optional(list(string))<br/>          instance_generations                                    = optional(list(string))<br/>          local_storage                                           = optional(string)<br/>          local_storage_types                                     = optional(list(string))<br/>          max_spot_price_as_percentage_of_optimal_on_demand_price = optional(number)<br/>          memory_gib_per_vcpu = optional(object({<br/>            max = optional(number)<br/>            min = optional(number)<br/>          }))<br/>          memory_mib = optional(object({<br/>            max = optional(number)<br/>            min = optional(number)<br/>          }))<br/>          network_bandwidth_gbps = optional(object({<br/>            max = optional(number)<br/>            min = optional(number)<br/>          }))<br/>          network_interface_count = optional(object({<br/>            max = optional(number)<br/>            min = optional(number)<br/>          }))<br/>          on_demand_max_price_percentage_over_lowest_price = optional(number)<br/>          require_hibernate_support                        = optional(bool)<br/>          spot_max_price_percentage_over_lowest_price      = optional(number)<br/>          total_local_storage_gb = optional(object({<br/>            max = optional(number)<br/>            min = optional(number)<br/>          }))<br/>          vcpu_count = optional(object({<br/>            max = optional(number)<br/>            min = optional(number)<br/>          }))<br/>        }))<br/>        monitoring = optional(string)<br/>        network_configuration = optional(object({<br/>          security_groups = optional(list(string), [])<br/>          subnets         = list(string)<br/>        }))<br/>        storage_configuration = optional(object({<br/>          storage_size_gib = number<br/>        }))<br/>      })<br/>      propagate_tags = optional(string, "CAPACITY_PROVIDER")<br/>    }))<br/>    name = optional(string) # Will fall back to use map key if not set<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `null` | no |
| <a name="input_cloudwatch_log_group_class"></a> [cloudwatch\_log\_group\_class](#input\_cloudwatch\_log\_group\_class) | Specified the log class of the log group. Possible values are: `STANDARD` or `INFREQUENT_ACCESS` | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch\_log\_group\_kms\_key\_id](#input\_cloudwatch\_log\_group\_kms\_key\_id) | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Custom name of CloudWatch Log Group for ECS cluster | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events | `number` | `90` | no |
| <a name="input_cloudwatch_log_group_tags"></a> [cloudwatch\_log\_group\_tags](#input\_cloudwatch\_log\_group\_tags) | A map of additional tags to add to the log group created | `map(string)` | `{}` | no |
| <a name="input_cluster_capacity_providers"></a> [cluster\_capacity\_providers](#input\_cluster\_capacity\_providers) | List of capacity provider names to associate with the ECS cluster. Note: any capacity providers created by this module will be automatically added | `list(string)` | `[]` | no |
| <a name="input_cluster_capacity_providers_wait_duration"></a> [cluster\_capacity\_providers\_wait\_duration](#input\_cluster\_capacity\_providers\_wait\_duration) | Duration to wait after the ECS cluster has become active before attaching the cluster capacity providers | `string` | `"20s"` | no |
| <a name="input_configuration"></a> [configuration](#input\_configuration) | The execute command configuration for the cluster | <pre>object({<br/>    execute_command_configuration = optional(object({<br/>      kms_key_id = optional(string)<br/>      log_configuration = optional(object({<br/>        cloud_watch_encryption_enabled = optional(bool)<br/>        cloud_watch_log_group_name     = optional(string)<br/>        s3_bucket_encryption_enabled   = optional(bool)<br/>        s3_bucket_name                 = optional(string)<br/>        s3_kms_key_id                  = optional(string)<br/>        s3_key_prefix                  = optional(string)<br/>      }))<br/>      logging = optional(string, "OVERRIDE")<br/>    }))<br/>    managed_storage_configuration = optional(object({<br/>      fargate_ephemeral_storage_kms_key_id = optional(string)<br/>      kms_key_id                           = optional(string)<br/>    }))<br/>  })</pre> | <pre>{<br/>  "execute_command_configuration": {<br/>    "log_configuration": {<br/>      "cloud_watch_log_group_name": "placeholder"<br/>    }<br/>  }<br/>}</pre> | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether resources will be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled | `bool` | `true` | no |
| <a name="input_create_infrastructure_iam_role"></a> [create\_infrastructure\_iam\_role](#input\_create\_infrastructure\_iam\_role) | Determines whether the ECS infrastructure IAM role should be created | `bool` | `true` | no |
| <a name="input_create_node_iam_instance_profile"></a> [create\_node\_iam\_instance\_profile](#input\_create\_node\_iam\_instance\_profile) | Determines whether an IAM instance profile is created or to use an existing IAM instance profile | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Determines if a security group is created | `bool` | `true` | no |
| <a name="input_create_task_exec_iam_role"></a> [create\_task\_exec\_iam\_role](#input\_create\_task\_exec\_iam\_role) | Determines whether the ECS task definition IAM role should be created | `bool` | `false` | no |
| <a name="input_create_task_exec_policy"></a> [create\_task\_exec\_policy](#input\_create\_task\_exec\_policy) | Determines whether the ECS task definition IAM policy should be created. This includes permissions included in AmazonECSTaskExecutionRolePolicy as well as access to secrets and SSM parameters | `bool` | `true` | no |
| <a name="input_default_capacity_provider_strategy"></a> [default\_capacity\_provider\_strategy](#input\_default\_capacity\_provider\_strategy) | Map of default capacity provider strategy definitions to use for the cluster | <pre>map(object({<br/>    base   = optional(number)<br/>    name   = optional(string) # Will fall back to use map key if not set<br/>    weight = optional(number)<br/>  }))</pre> | `{}` | no |
| <a name="input_disable_v7_default_name_description"></a> [disable\_v7\_default\_name\_description](#input\_disable\_v7\_default\_name\_description) | [DEPRECATED - will be removed in v8.0] Determines whether to disable the default postfix added to resource names and descriptions added in v7.0 | `bool` | `false` | no |
| <a name="input_infrastructure_iam_role_description"></a> [infrastructure\_iam\_role\_description](#input\_infrastructure\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_infrastructure_iam_role_name"></a> [infrastructure\_iam\_role\_name](#input\_infrastructure\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_infrastructure_iam_role_override_policy_documents"></a> [infrastructure\_iam\_role\_override\_policy\_documents](#input\_infrastructure\_iam\_role\_override\_policy\_documents) | List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid` | `list(string)` | `[]` | no |
| <a name="input_infrastructure_iam_role_path"></a> [infrastructure\_iam\_role\_path](#input\_infrastructure\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_infrastructure_iam_role_permissions_boundary"></a> [infrastructure\_iam\_role\_permissions\_boundary](#input\_infrastructure\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_infrastructure_iam_role_source_policy_documents"></a> [infrastructure\_iam\_role\_source\_policy\_documents](#input\_infrastructure\_iam\_role\_source\_policy\_documents) | List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s | `list(string)` | `[]` | no |
| <a name="input_infrastructure_iam_role_statements"></a> [infrastructure\_iam\_role\_statements](#input\_infrastructure\_iam\_role\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | <pre>map(object({<br/>    sid           = optional(string)<br/>    actions       = optional(list(string))<br/>    not_actions   = optional(list(string))<br/>    effect        = optional(string, "Allow")<br/>    resources     = optional(list(string))<br/>    not_resources = optional(list(string))<br/>    principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    not_principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    condition = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_infrastructure_iam_role_tags"></a> [infrastructure\_iam\_role\_tags](#input\_infrastructure\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_infrastructure_iam_role_use_name_prefix"></a> [infrastructure\_iam\_role\_use\_name\_prefix](#input\_infrastructure\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the cluster (up to 255 letters, numbers, hyphens, and underscores) | `string` | `""` | no |
| <a name="input_node_iam_role_additional_policies"></a> [node\_iam\_role\_additional\_policies](#input\_node\_iam\_role\_additional\_policies) | Additional policies to be added to the IAM role | `map(string)` | `{}` | no |
| <a name="input_node_iam_role_description"></a> [node\_iam\_role\_description](#input\_node\_iam\_role\_description) | Description of the role | `string` | `"ECS Managed Instances node IAM role"` | no |
| <a name="input_node_iam_role_name"></a> [node\_iam\_role\_name](#input\_node\_iam\_role\_name) | Name to use on IAM role/instance profile created | `string` | `null` | no |
| <a name="input_node_iam_role_override_policy_documents"></a> [node\_iam\_role\_override\_policy\_documents](#input\_node\_iam\_role\_override\_policy\_documents) | List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid` | `list(string)` | `[]` | no |
| <a name="input_node_iam_role_path"></a> [node\_iam\_role\_path](#input\_node\_iam\_role\_path) | IAM role/instance profile path | `string` | `null` | no |
| <a name="input_node_iam_role_permissions_boundary"></a> [node\_iam\_role\_permissions\_boundary](#input\_node\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_node_iam_role_source_policy_documents"></a> [node\_iam\_role\_source\_policy\_documents](#input\_node\_iam\_role\_source\_policy\_documents) | List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s | `list(string)` | `[]` | no |
| <a name="input_node_iam_role_statements"></a> [node\_iam\_role\_statements](#input\_node\_iam\_role\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | <pre>map(object({<br/>    sid           = optional(string)<br/>    actions       = optional(list(string))<br/>    not_actions   = optional(list(string))<br/>    effect        = optional(string, "Allow")<br/>    resources     = optional(list(string))<br/>    not_resources = optional(list(string))<br/>    principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    not_principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    condition = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_node_iam_role_tags"></a> [node\_iam\_role\_tags](#input\_node\_iam\_role\_tags) | A map of additional tags to add to the IAM role/instance profile created | `map(string)` | `{}` | no |
| <a name="input_node_iam_role_use_name_prefix"></a> [node\_iam\_role\_use\_name\_prefix](#input\_node\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role/instance profile name (`node_iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description of the security group created | `string` | `null` | no |
| <a name="input_security_group_egress_rules"></a> [security\_group\_egress\_rules](#input\_security\_group\_egress\_rules) | Security group egress rules to add to the security group created | <pre>map(object({<br/>    name = optional(string)<br/><br/>    cidr_ipv4                    = optional(string)<br/>    cidr_ipv6                    = optional(string)<br/>    description                  = optional(string)<br/>    from_port                    = optional(string)<br/>    ip_protocol                  = optional(string, "tcp")<br/>    prefix_list_id               = optional(string)<br/>    referenced_security_group_id = optional(string)<br/>    tags                         = optional(map(string), {})<br/>    to_port                      = optional(string)<br/>  }))</pre> | <pre>{<br/>  "all_ipv4": {<br/>    "cidr_ipv4": "0.0.0.0/0",<br/>    "description": "Allow all IPv4 traffic",<br/>    "ip_protocol": "-1"<br/>  },<br/>  "all_ipv6": {<br/>    "cidr_ipv6": "::/0",<br/>    "description": "Allow all IPv6 traffic",<br/>    "ip_protocol": "-1"<br/>  }<br/>}</pre> | no |
| <a name="input_security_group_ingress_rules"></a> [security\_group\_ingress\_rules](#input\_security\_group\_ingress\_rules) | Security group ingress rules to add to the security group created | <pre>map(object({<br/>    name = optional(string)<br/><br/>    cidr_ipv4                    = optional(string)<br/>    cidr_ipv6                    = optional(string)<br/>    description                  = optional(string)<br/>    from_port                    = optional(string)<br/>    ip_protocol                  = optional(string, "tcp")<br/>    prefix_list_id               = optional(string)<br/>    referenced_security_group_id = optional(string)<br/>    tags                         = optional(map(string), {})<br/>    to_port                      = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name to use on security group created | `string` | `null` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | A map of additional tags to add to the security group created | `map(string)` | `{}` | no |
| <a name="input_security_group_use_name_prefix"></a> [security\_group\_use\_name\_prefix](#input\_security\_group\_use\_name\_prefix) | Determines whether the security group name (`security_group_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_service_connect_defaults"></a> [service\_connect\_defaults](#input\_service\_connect\_defaults) | Configures a default Service Connect namespace | <pre>object({<br/>    namespace = string<br/>  })</pre> | `null` | no |
| <a name="input_setting"></a> [setting](#input\_setting) | List of configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "name": "containerInsights",<br/>    "value": "enabled"<br/>  }<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_task_exec_iam_role_description"></a> [task\_exec\_iam\_role\_description](#input\_task\_exec\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_task_exec_iam_role_name"></a> [task\_exec\_iam\_role\_name](#input\_task\_exec\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_task_exec_iam_role_path"></a> [task\_exec\_iam\_role\_path](#input\_task\_exec\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_task_exec_iam_role_permissions_boundary"></a> [task\_exec\_iam\_role\_permissions\_boundary](#input\_task\_exec\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_task_exec_iam_role_policies"></a> [task\_exec\_iam\_role\_policies](#input\_task\_exec\_iam\_role\_policies) | Map of IAM role policy ARNs to attach to the IAM role | `map(string)` | `{}` | no |
| <a name="input_task_exec_iam_role_tags"></a> [task\_exec\_iam\_role\_tags](#input\_task\_exec\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_task_exec_iam_role_use_name_prefix"></a> [task\_exec\_iam\_role\_use\_name\_prefix](#input\_task\_exec\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`task_exec_iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_task_exec_iam_statements"></a> [task\_exec\_iam\_statements](#input\_task\_exec\_iam\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | <pre>map(object({<br/>    sid           = optional(string)<br/>    actions       = optional(list(string))<br/>    not_actions   = optional(list(string))<br/>    effect        = optional(string, "Allow")<br/>    resources     = optional(list(string))<br/>    not_resources = optional(list(string))<br/>    principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    not_principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    condition = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_task_exec_secret_arns"></a> [task\_exec\_secret\_arns](#input\_task\_exec\_secret\_arns) | List of SecretsManager secret ARNs the task execution role will be permitted to get/read | `list(string)` | `[]` | no |
| <a name="input_task_exec_ssm_param_arns"></a> [task\_exec\_ssm\_param\_arns](#input\_task\_exec\_ssm\_param\_arns) | List of SSM parameter ARNs the task execution role will be permitted to get/read | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the security group will be created | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN that identifies the cluster |
| <a name="output_capacity_providers"></a> [capacity\_providers](#output\_capacity\_providers) | Map of autoscaling capacity providers created and their attributes |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of CloudWatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of CloudWatch log group created |
| <a name="output_cluster_capacity_providers"></a> [cluster\_capacity\_providers](#output\_cluster\_capacity\_providers) | Map of cluster capacity providers attributes |
| <a name="output_id"></a> [id](#output\_id) | ID that identifies the cluster |
| <a name="output_infrastructure_iam_role_arn"></a> [infrastructure\_iam\_role\_arn](#output\_infrastructure\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_infrastructure_iam_role_name"></a> [infrastructure\_iam\_role\_name](#output\_infrastructure\_iam\_role\_name) | IAM role name |
| <a name="output_infrastructure_iam_role_unique_id"></a> [infrastructure\_iam\_role\_unique\_id](#output\_infrastructure\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_name"></a> [name](#output\_name) | Name that identifies the cluster |
| <a name="output_node_iam_instance_profile_arn"></a> [node\_iam\_instance\_profile\_arn](#output\_node\_iam\_instance\_profile\_arn) | ARN assigned by AWS to the instance profile |
| <a name="output_node_iam_instance_profile_id"></a> [node\_iam\_instance\_profile\_id](#output\_node\_iam\_instance\_profile\_id) | Instance profile's ID |
| <a name="output_node_iam_instance_profile_unique"></a> [node\_iam\_instance\_profile\_unique](#output\_node\_iam\_instance\_profile\_unique) | Stable and unique string identifying the IAM instance profile |
| <a name="output_node_iam_role_arn"></a> [node\_iam\_role\_arn](#output\_node\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_node_iam_role_name"></a> [node\_iam\_role\_name](#output\_node\_iam\_role\_name) | IAM role name |
| <a name="output_node_iam_role_unique_id"></a> [node\_iam\_role\_unique\_id](#output\_node\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_task_exec_iam_role_arn"></a> [task\_exec\_iam\_role\_arn](#output\_task\_exec\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_task_exec_iam_role_name"></a> [task\_exec\_iam\_role\_name](#output\_task\_exec\_iam\_role\_name) | IAM role name |
| <a name="output_task_exec_iam_role_unique_id"></a> [task\_exec\_iam\_role\_unique\_id](#output\_task\_exec\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
<!-- END_TF_DOCS -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/LICENSE).
