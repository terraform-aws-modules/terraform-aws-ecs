data "aws_region" "current" {
  region = var.region

  count = var.create ? 1 : 0
}
data "aws_partition" "current" {
  count = var.create ? 1 : 0
}
data "aws_caller_identity" "current" {
  count = var.create ? 1 : 0
}

locals {
  account_id = try(data.aws_caller_identity.current[0].account_id, "")
  partition  = try(data.aws_partition.current[0].partition, "")
  region     = try(data.aws_region.current[0].region, "")
}

################################################################################
# Cluster
################################################################################

resource "aws_ecs_cluster" "this" {
  count = var.create ? 1 : 0

  region = var.region

  dynamic "configuration" {
    for_each = var.configuration != null ? [var.configuration] : []

    content {
      dynamic "execute_command_configuration" {
        for_each = configuration.value.execute_command_configuration != null ? [configuration.value.execute_command_configuration] : []

        content {
          kms_key_id = execute_command_configuration.value.kms_key_id

          dynamic "log_configuration" {
            for_each = execute_command_configuration.value.log_configuration != null ? [execute_command_configuration.value.log_configuration] : []

            content {
              cloud_watch_encryption_enabled = log_configuration.value.cloud_watch_encryption_enabled
              cloud_watch_log_group_name     = try(aws_cloudwatch_log_group.this[0].name, log_configuration.value.cloud_watch_log_group_name)
              s3_bucket_encryption_enabled   = log_configuration.value.s3_bucket_encryption_enabled
              s3_bucket_name                 = log_configuration.value.s3_bucket_name
              s3_key_prefix                  = log_configuration.value.s3_key_prefix
            }
          }

          logging = execute_command_configuration.value.logging
        }
      }

      dynamic "managed_storage_configuration" {
        for_each = configuration.value.managed_storage_configuration != null ? [configuration.value.managed_storage_configuration] : []

        content {
          fargate_ephemeral_storage_kms_key_id = managed_storage_configuration.value.fargate_ephemeral_storage_kms_key_id
          kms_key_id                           = managed_storage_configuration.value.kms_key_id
        }
      }
    }
  }

  name = var.name

  dynamic "service_connect_defaults" {
    for_each = var.service_connect_defaults != null ? [var.service_connect_defaults] : []

    content {
      namespace = service_connect_defaults.value.namespace
    }
  }

  dynamic "setting" {
    for_each = var.setting != null ? var.setting : []

    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }

  tags = var.tags
}

################################################################################
# CloudWatch Log Group
################################################################################

locals {
  log_group_name = try(coalesce(var.cloudwatch_log_group_name, "/aws/ecs/${var.name}"), "")
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create && var.create_cloudwatch_log_group ? 1 : 0

  region = var.region

  name              = local.log_group_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id
  log_group_class   = var.cloudwatch_log_group_class

  tags = merge(
    var.tags,
    var.cloudwatch_log_group_tags,
    { Name = local.log_group_name }
  )
}

################################################################################
# Cluster Capacity Providers
################################################################################

# The managed instance capacity provider returns quickly in a `CREATING` state,
# but we need to wait for it to be in the `ACTIVE` state before associating it with the cluster.
resource "time_sleep" "this" {
  count = var.create ? 1 : 0

  create_duration = var.cluster_capacity_providers_wait_duration

  triggers = {
    # Triggers wants a string so we have to do some cheap serialization/deserialization to transport correctly
    capacity_provider_names = var.capacity_providers != null ? join(",", [for k, v in var.capacity_providers : aws_ecs_capacity_provider.this[k].name]) : ""
    # This is done so that the output of `capacity_providers` also waits for them to be `ACTIVE`
    # for the scenarios where users define separate cluster and service modules (serivce needs the provider to be ACTIVE)
    capacity_providers = var.capacity_providers != null ? jsonencode(aws_ecs_capacity_provider.this) : ""
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  count = var.create ? 1 : 0

  region = var.region

  cluster_name       = aws_ecs_cluster.this[0].name
  capacity_providers = distinct(concat(var.cluster_capacity_providers, compact(split(",", time_sleep.this[0].triggers["capacity_provider_names"]))))

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-capacity-providers.html#capacity-providers-considerations
  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy != null ? var.default_capacity_provider_strategy : {}

    content {
      base              = default_capacity_provider_strategy.value.base
      capacity_provider = try(coalesce(default_capacity_provider_strategy.value.name, default_capacity_provider_strategy.key))
      weight            = coalesce(default_capacity_provider_strategy.value.weight, 1)
    }
  }
}

################################################################################
# Capacity Provider
################################################################################

locals {
  managed_instances_enabled = var.capacity_providers != null ? anytrue([for k, v in var.capacity_providers : v.managed_instances_provider != null]) : false
}

resource "aws_ecs_capacity_provider" "this" {
  for_each = var.create && var.capacity_providers != null ? var.capacity_providers : {}

  region = var.region

  dynamic "auto_scaling_group_provider" {
    for_each = each.value.auto_scaling_group_provider != null ? [each.value.auto_scaling_group_provider] : []

    content {
      auto_scaling_group_arn = auto_scaling_group_provider.value.auto_scaling_group_arn
      managed_draining       = auto_scaling_group_provider.value.managed_draining

      dynamic "managed_scaling" {
        for_each = auto_scaling_group_provider.value.managed_scaling != null ? [auto_scaling_group_provider.value.managed_scaling] : []

        content {
          instance_warmup_period    = managed_scaling.value.instance_warmup_period
          maximum_scaling_step_size = managed_scaling.value.maximum_scaling_step_size
          minimum_scaling_step_size = managed_scaling.value.minimum_scaling_step_size
          status                    = managed_scaling.value.status
          target_capacity           = managed_scaling.value.target_capacity
        }
      }

      # When you use managed termination protection, you must also use managed scaling otherwise managed termination protection won't work
      managed_termination_protection = auto_scaling_group_provider.value.managed_scaling != null ? auto_scaling_group_provider.value.managed_termination_protection : "DISABLED"
    }
  }

  dynamic "managed_instances_provider" {
    for_each = each.value.managed_instances_provider != null ? [each.value.managed_instances_provider] : []

    content {
      infrastructure_role_arn = local.create_infrastructure_iam_role ? aws_iam_role.infrastructure[0].arn : managed_instances_provider.value.infrastructure_role_arn

      dynamic "instance_launch_template" {
        for_each = managed_instances_provider.value.instance_launch_template != null ? [managed_instances_provider.value.instance_launch_template] : []

        content {
          capacity_option_type     = instance_launch_template.value.capacity_option_type
          ec2_instance_profile_arn = local.create_node_iam_instance_profile ? aws_iam_instance_profile.this[0].arn : instance_launch_template.value.ec2_instance_profile_arn

          dynamic "instance_requirements" {
            for_each = instance_launch_template.value.instance_requirements != null ? [instance_launch_template.value.instance_requirements] : []

            content {
              dynamic "accelerator_count" {
                for_each = instance_requirements.value.accelerator_count != null ? [instance_requirements.value.accelerator_count] : []

                content {
                  max = accelerator_count.value.max
                  min = accelerator_count.value.min
                }
              }

              accelerator_manufacturers = instance_requirements.value.accelerator_manufacturers
              accelerator_names         = instance_requirements.value.accelerator_names

              dynamic "accelerator_total_memory_mib" {
                for_each = instance_requirements.value.accelerator_total_memory_mib != null ? [instance_requirements.value.accelerator_total_memory_mib] : []

                content {
                  max = accelerator_total_memory_mib.value.max
                  min = accelerator_total_memory_mib.value.min
                }
              }

              accelerator_types      = instance_requirements.value.accelerator_types
              allowed_instance_types = instance_requirements.value.allowed_instance_types
              bare_metal             = instance_requirements.value.bare_metal

              dynamic "baseline_ebs_bandwidth_mbps" {
                for_each = instance_requirements.value.baseline_ebs_bandwidth_mbps != null ? [instance_requirements.value.baseline_ebs_bandwidth_mbps] : []

                content {
                  max = baseline_ebs_bandwidth_mbps.value.max
                  min = baseline_ebs_bandwidth_mbps.value.min
                }
              }

              burstable_performance                                   = instance_requirements.value.burstable_performance
              cpu_manufacturers                                       = instance_requirements.value.cpu_manufacturers
              excluded_instance_types                                 = instance_requirements.value.excluded_instance_types
              instance_generations                                    = instance_requirements.value.instance_generations
              local_storage                                           = instance_requirements.value.local_storage
              local_storage_types                                     = instance_requirements.value.local_storage_types
              max_spot_price_as_percentage_of_optimal_on_demand_price = instance_requirements.value.max_spot_price_as_percentage_of_optimal_on_demand_price

              dynamic "memory_gib_per_vcpu" {
                for_each = instance_requirements.value.memory_gib_per_vcpu != null ? [instance_requirements.value.memory_gib_per_vcpu] : []

                content {
                  max = memory_gib_per_vcpu.value.max
                  min = memory_gib_per_vcpu.value.min
                }
              }

              dynamic "memory_mib" {
                for_each = instance_requirements.value.memory_mib != null ? [instance_requirements.value.memory_mib] : []

                content {
                  max = memory_mib.value.max
                  min = memory_mib.value.min
                }
              }

              dynamic "network_bandwidth_gbps" {
                for_each = instance_requirements.value.network_bandwidth_gbps != null ? [instance_requirements.value.network_bandwidth_gbps] : []

                content {
                  max = network_bandwidth_gbps.value.max
                  min = network_bandwidth_gbps.value.min
                }
              }

              dynamic "network_interface_count" {
                for_each = instance_requirements.value.network_interface_count != null ? [instance_requirements.value.network_interface_count] : []

                content {
                  max = network_interface_count.value.max
                  min = network_interface_count.value.min
                }
              }

              on_demand_max_price_percentage_over_lowest_price = instance_requirements.value.on_demand_max_price_percentage_over_lowest_price
              require_hibernate_support                        = instance_requirements.value.require_hibernate_support
              spot_max_price_percentage_over_lowest_price      = instance_requirements.value.spot_max_price_percentage_over_lowest_price

              dynamic "total_local_storage_gb" {
                for_each = instance_requirements.value.total_local_storage_gb != null ? [instance_requirements.value.total_local_storage_gb] : []

                content {
                  max = total_local_storage_gb.value.max
                  min = total_local_storage_gb.value.min
                }
              }

              dynamic "vcpu_count" {
                for_each = instance_requirements.value.vcpu_count != null ? [instance_requirements.value.vcpu_count] : []

                content {
                  max = vcpu_count.value.max
                  min = vcpu_count.value.min
                }
              }
            }
          }

          monitoring = instance_launch_template.value.monitoring

          dynamic "network_configuration" {
            for_each = instance_launch_template.value.network_configuration != null ? [instance_launch_template.value.network_configuration] : []

            content {
              security_groups = local.create_security_group ? flatten(concat(aws_security_group.this[*].id, network_configuration.value.security_groups)) : network_configuration.value.security_groups
              subnets         = network_configuration.value.subnets
            }
          }

          dynamic "storage_configuration" {
            for_each = instance_launch_template.value.storage_configuration != null ? [instance_launch_template.value.storage_configuration] : []

            content {
              storage_size_gib = storage_configuration.value.storage_size_gib
            }
          }
        }
      }

      propagate_tags = managed_instances_provider.value.propagate_tags
    }
  }

  cluster = each.value.managed_instances_provider != null ? aws_ecs_cluster.this[0].name : null

  name = try(coalesce(each.value.name, each.key), "")

  tags = merge(
    var.tags,
    each.value.tags,
  )

  # What an awful friggin service API they created with managed instances
  depends_on = [
    aws_iam_role_policy_attachment.task_exec,
    aws_iam_role_policy_attachment.infrastructure,
    aws_iam_role_policy_attachment.node,
    aws_vpc_security_group_ingress_rule.this,
    aws_vpc_security_group_egress_rule.this,
  ]
}

################################################################################
# Task Execution - IAM Role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
################################################################################

locals {
  task_exec_iam_role_name = try(coalesce(var.task_exec_iam_role_name, "${var.name}${var.disable_v7_default_name_description ? "" : "-task-exec"}"), "")

  create_task_exec_iam_role = var.create && var.create_task_exec_iam_role
  create_task_exec_policy   = local.create_task_exec_iam_role && var.create_task_exec_policy
}

data "aws_iam_policy_document" "task_exec_assume" {
  count = local.create_task_exec_iam_role ? 1 : 0

  statement {
    sid     = "ECSTaskExecutionAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_exec" {
  count = local.create_task_exec_iam_role ? 1 : 0

  name        = var.task_exec_iam_role_use_name_prefix ? null : local.task_exec_iam_role_name
  name_prefix = var.task_exec_iam_role_use_name_prefix ? "${local.task_exec_iam_role_name}-" : null
  path        = var.task_exec_iam_role_path
  description = coalesce(var.task_exec_iam_role_description, "Task execution role for ${var.name}")

  assume_role_policy    = data.aws_iam_policy_document.task_exec_assume[0].json
  permissions_boundary  = var.task_exec_iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.task_exec_iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "task_exec_additional" {
  for_each = { for k, v in var.task_exec_iam_role_policies : k => v if local.create_task_exec_iam_role }

  role       = aws_iam_role.task_exec[0].name
  policy_arn = each.value
}

data "aws_iam_policy_document" "task_exec" {
  count = local.create_task_exec_policy ? 1 : 0

  # Pulled from AmazonECSTaskExecutionRolePolicy
  statement {
    sid = "Logs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  # Pulled from AmazonECSTaskExecutionRolePolicy
  statement {
    sid = "ECR"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(var.task_exec_ssm_param_arns) > 0 ? [1] : []

    content {
      sid       = "GetSSMParams"
      actions   = ["ssm:GetParameters"]
      resources = var.task_exec_ssm_param_arns
    }
  }

  dynamic "statement" {
    for_each = length(var.task_exec_secret_arns) > 0 ? [1] : []

    content {
      sid       = "GetSecrets"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = var.task_exec_secret_arns
    }
  }

  dynamic "statement" {
    for_each = var.task_exec_iam_statements != null ? var.task_exec_iam_statements : {}

    content {
      sid           = try(coalesce(statement.value.sid, statement.key))
      actions       = statement.value.actions
      not_actions   = statement.value.not_actions
      effect        = statement.value.effect
      resources     = statement.value.resources
      not_resources = statement.value.not_resources

      dynamic "principals" {
        for_each = statement.value.principals != null ? statement.value.principals : []

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = statement.value.not_principals != null ? statement.value.not_principals : []

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.condition != null ? statement.value.condition : []

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_policy" "task_exec" {
  count = local.create_task_exec_policy ? 1 : 0

  name        = var.task_exec_iam_role_use_name_prefix ? null : local.task_exec_iam_role_name
  name_prefix = var.task_exec_iam_role_use_name_prefix ? "${local.task_exec_iam_role_name}-" : null
  description = coalesce(var.task_exec_iam_role_description, "Task execution role IAM policy")
  policy      = data.aws_iam_policy_document.task_exec[0].json

  tags = merge(var.tags, var.task_exec_iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "task_exec" {
  count = local.create_task_exec_policy ? 1 : 0

  role       = aws_iam_role.task_exec[0].name
  policy_arn = aws_iam_policy.task_exec[0].arn
}

############################################################################################
# Infrastructure IAM role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/infrastructure_IAM_role.html
############################################################################################

locals {
  create_infrastructure_iam_role = var.create && var.create_infrastructure_iam_role && local.managed_instances_enabled

  infrastructure_iam_role_name = coalesce(var.infrastructure_iam_role_name, "${var.name}-infra")
}

data "aws_iam_policy_document" "infrastructure_assume" {
  count = local.create_infrastructure_iam_role ? 1 : 0

  statement {
    sid = "ECSServiceAssumeRole"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "infrastructure" {
  count = local.create_infrastructure_iam_role ? 1 : 0

  name        = var.infrastructure_iam_role_use_name_prefix ? null : local.infrastructure_iam_role_name
  name_prefix = var.infrastructure_iam_role_use_name_prefix ? "${local.infrastructure_iam_role_name}-" : null
  path        = var.infrastructure_iam_role_path
  description = coalesce(var.infrastructure_iam_role_description, "Amazon ECS infrastructure IAM role that is used to manage your infrastructure (managed instances)")

  assume_role_policy    = data.aws_iam_policy_document.infrastructure_assume[0].json
  permissions_boundary  = var.infrastructure_iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.infrastructure_iam_role_tags)
}

################################################################################
# Infrastructure IAM role policy
#
# The managed policy requires role names to start with `ecsInstanceRole`
# So we are duplicating the policy here to avoid that unfortunate and surprising requirement
#
# Ref: https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonECSInfrastructureRolePolicyForManagedInstances.html
################################################################################

data "aws_iam_policy_document" "infrastructure" {
  count = local.create_infrastructure_iam_role ? 1 : 0

  source_policy_documents   = var.infrastructure_iam_role_source_policy_documents
  override_policy_documents = var.infrastructure_iam_role_override_policy_documents

  statement {
    sid       = "CreateLaunchTemplateForManagedInstances"
    actions   = ["ec2:CreateLaunchTemplate"]
    resources = ["arn:${local.partition}:ec2:${local.region}:${local.account_id}:launch-template/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/AmazonECSManaged"
      values   = [true]
    }
  }

  statement {
    sid = "CreateLaunchTemplateVersionsForManagedInstances"
    actions = [
      "ec2:CreateLaunchTemplateVersion",
      "ec2:ModifyLaunchTemplate",
    ]
    resources = ["arn:${local.partition}:ec2:${local.region}:${local.account_id}:launch-template/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ManagedResourceOperator"
      values   = ["ecs.amazonaws.com"]
    }
  }

  statement {
    sid     = "ProvisionEC2InstancesForManagedInstances"
    actions = ["ec2:CreateFleet"]
    resources = [
      "arn:${local.partition}:ec2:${local.region}:*:fleet/*",
      "arn:${local.partition}:ec2:${local.region}:*:instance/*",
      "arn:${local.partition}:ec2:${local.region}:*:network-interface/*",
      "arn:${local.partition}:ec2:${local.region}:*:launch-template/*",
      "arn:${local.partition}:ec2:${local.region}:*:volume/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/AmazonECSManaged"
      values   = [true]
    }
  }

  statement {
    sid     = "CreateFleetForSupportingResources"
    actions = ["ec2:CreateFleet"]
    resources = [
      "arn:${local.partition}:ec2:${local.region}:*:subnet/*",
      "arn:${local.partition}:ec2:${local.region}:*:security-group/*",
      "arn:${local.partition}:ec2:${local.region}:*:image/*",
    ]
  }

  statement {
    sid     = "RunInstancesForManagedInstances"
    actions = ["ec2:RunInstances"]
    resources = [
      "arn:${local.partition}:ec2:${local.region}:*:instance/*",
      "arn:${local.partition}:ec2:${local.region}:*:volume/*",
      "arn:${local.partition}:ec2:${local.region}:*:network-interface/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/AmazonECSManaged"
      values   = [true]
    }
  }

  statement {
    sid       = "RunInstancesForECSManagedLaunchTemplates"
    actions   = ["ec2:RunInstances"]
    resources = ["arn:${local.partition}:ec2:${local.region}:*:launch-template/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/AmazonECSManaged"
      values   = [true]
    }
  }

  statement {
    sid     = "RunInstancesForSupportingResources"
    actions = ["ec2:RunInstances"]
    resources = [
      "arn:${local.partition}:ec2:${local.region}:*:subnet/*",
      "arn:${local.partition}:ec2:${local.region}:*:security-group/*",
      "arn:${local.partition}:ec2:${local.region}:*:image/*",
    ]
  }

  statement {
    sid     = "TagOnCreateEC2ResourcesForManagedInstances"
    actions = ["ec2:CreateTags"]
    resources = [
      "arn:${local.partition}:ec2:${local.region}:*:fleet/*",
      "arn:${local.partition}:ec2:${local.region}:*:launch-template/*",
      "arn:${local.partition}:ec2:${local.region}:*:network-interface/*",
      "arn:${local.partition}:ec2:${local.region}:*:instance/*",
      "arn:${local.partition}:ec2:${local.region}:*:volume/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values = [
        "CreateFleet",
        "CreateLaunchTemplate",
        "RunInstances",
      ]
    }
  }

  statement {
    sid       = "PassInstanceRoleForManagedInstances"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.node[0].arn]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }

  statement {
    sid       = "CreateServiceLinkedRoleForEC2Spot"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["arn:${local.partition}:iam::${local.account_id}:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot"]
  }

  statement {
    sid = "DescribeEC2ResourcesManagedByECS"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.infrastructure_iam_role_statements != null ? var.infrastructure_iam_role_statements : {}

    content {
      sid           = try(coalesce(statement.value.sid, statement.key))
      actions       = statement.value.actions
      not_actions   = statement.value.not_actions
      effect        = statement.value.effect
      resources     = statement.value.resources
      not_resources = statement.value.not_resources

      dynamic "principals" {
        for_each = statement.value.principals != null ? statement.value.principals : []

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = statement.value.not_principals != null ? statement.value.not_principals : []

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.condition != null ? statement.value.condition : []

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_policy" "infrastructure" {
  count = local.create_infrastructure_iam_role ? 1 : 0

  name        = var.infrastructure_iam_role_use_name_prefix ? null : local.infrastructure_iam_role_name
  name_prefix = var.infrastructure_iam_role_use_name_prefix ? "${local.infrastructure_iam_role_name}-" : null
  description = coalesce(var.infrastructure_iam_role_description, "ECS Managed Instances infrastructure role permissions")
  policy      = data.aws_iam_policy_document.infrastructure[0].json

  tags = merge(var.tags, var.infrastructure_iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "infrastructure" {
  count = local.create_infrastructure_iam_role ? 1 : 0

  policy_arn = aws_iam_policy.infrastructure[0].arn
  role       = aws_iam_role.infrastructure[0].name
}

################################################################################
# Node IAM role
################################################################################

locals {
  create_node_iam_instance_profile = var.create && var.create_node_iam_instance_profile && local.managed_instances_enabled

  node_iam_role_name = coalesce(var.node_iam_role_name, "${var.name}-node")
}

data "aws_iam_policy_document" "node_assume_role_policy" {
  count = local.create_node_iam_instance_profile ? 1 : 0

  statement {
    sid = "ECSNodeAssumeRole"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  count = local.create_node_iam_instance_profile ? 1 : 0

  name        = var.node_iam_role_use_name_prefix ? null : local.node_iam_role_name
  name_prefix = var.node_iam_role_use_name_prefix ? "${local.node_iam_role_name}-" : null
  path        = var.node_iam_role_path
  description = coalesce(var.node_iam_role_description, "Amazon ECS managed instance node role for ECS cluster ${var.name}")

  assume_role_policy    = data.aws_iam_policy_document.node_assume_role_policy[0].json
  permissions_boundary  = var.node_iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.node_iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "node_additional" {
  for_each = { for k, v in var.node_iam_role_additional_policies : k => v if local.create_node_iam_instance_profile }

  policy_arn = each.value
  role       = aws_iam_role.node[0].name
}

################################################################################
# Node IAM role policy
#
# Due to this warning from ECS documentation
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/managed-instances-instance-profile.html
#
# > If you are using Amazon ECS Managed Instances with the AWS-managed Infrastructure policy,
# > the instance profile must be named ecsInstanceRole. If you are using a custom policy for
# > the Infrastructure role, the instance profile can have an alternative name.
#
# We default to creating the policy in order to remove this "surprising" requirement
# Ref: docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonECSInstanceRolePolicyForManagedInstances.html
################################################################################

data "aws_iam_policy_document" "node" {
  count = local.create_node_iam_instance_profile ? 1 : 0

  source_policy_documents   = var.node_iam_role_source_policy_documents
  override_policy_documents = var.node_iam_role_override_policy_documents

  statement {
    sid       = "ECSAgentDiscoverPollEndpointPermissions"
    actions   = ["ecs:DiscoverPollEndpoint"]
    resources = ["*"]
  }

  statement {
    sid       = "ECSAgentRegisterPermissions"
    actions   = ["ecs:RegisterContainerInstance"]
    resources = [aws_ecs_cluster.this[0].arn]
  }

  statement {
    sid       = "ECSAgentPollPermissions"
    actions   = ["ecs:Poll"]
    resources = ["arn:${local.partition}:ecs:${local.region}:${local.account_id}:container-instance/*"]
  }

  statement {
    sid = "ECSAgentTelemetryPermissions"
    actions = [
      "ecs:StartTelemetrySession",
      "ecs:PutSystemLogEvents",
    ]
    resources = ["arn:${local.partition}:ecs:${local.region}:${local.account_id}:container-instance/*"]
  }

  statement {
    sid = "ECSAgentStateChangePermissions"
    actions = [
      "ecs:SubmitAttachmentStateChanges",
      "ecs:SubmitTaskStateChange",
    ]
    resources = [aws_ecs_cluster.this[0].arn]
  }

  dynamic "statement" {
    for_each = var.node_iam_role_statements != null ? var.node_iam_role_statements : {}

    content {
      sid           = try(coalesce(statement.value.sid, statement.key))
      actions       = statement.value.actions
      not_actions   = statement.value.not_actions
      effect        = statement.value.effect
      resources     = statement.value.resources
      not_resources = statement.value.not_resources

      dynamic "principals" {
        for_each = statement.value.principals != null ? statement.value.principals : []

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = statement.value.not_principals != null ? statement.value.not_principals : []

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.condition != null ? statement.value.condition : []

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_policy" "node" {
  count = local.create_node_iam_instance_profile ? 1 : 0

  name        = var.node_iam_role_use_name_prefix ? null : local.node_iam_role_name
  name_prefix = var.node_iam_role_use_name_prefix ? "${local.node_iam_role_name}-" : null
  description = coalesce(var.node_iam_role_description, "ECS Managed Instances permissions")
  policy      = data.aws_iam_policy_document.node[0].json

  tags = merge(var.tags, var.node_iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "node" {
  count = local.create_node_iam_instance_profile ? 1 : 0

  policy_arn = aws_iam_policy.node[0].arn
  role       = aws_iam_role.node[0].name
}

################################################################################
# Node Instance Profile
################################################################################

resource "aws_iam_instance_profile" "this" {
  count = local.create_node_iam_instance_profile ? 1 : 0

  role = aws_iam_role.node[0].name

  name        = var.node_iam_role_use_name_prefix ? null : local.node_iam_role_name
  name_prefix = var.node_iam_role_use_name_prefix ? "${local.node_iam_role_name}-" : null
  path        = var.node_iam_role_path

  tags = merge(var.tags, var.node_iam_role_tags)

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Security Group
################################################################################

locals {
  create_security_group = var.create && var.create_security_group && local.managed_instances_enabled

  security_group_name = coalesce(var.security_group_name, "${var.name}${var.disable_v7_default_name_description ? "" : "-cluster"}")
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  region = var.region

  name        = var.security_group_use_name_prefix ? null : local.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.security_group_name}-" : null
  description = coalesce(var.security_group_description, "Security group for ECS managed instances in cluster ${aws_ecs_cluster.this[0].name}")
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    { Name = local.security_group_name },
    var.security_group_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = { for k, v in var.security_group_ingress_rules : k => v if var.security_group_ingress_rules != null && local.create_security_group }

  region = var.region

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = each.value.from_port
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id == "self" ? aws_security_group.this[0].id : each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  tags = merge(
    var.tags,
    var.security_group_tags,
    { "Name" = coalesce(each.value.name, "${local.security_group_name}-${each.key}") },
    each.value.tags
  )
  to_port = try(coalesce(each.value.to_port, each.value.from_port), null)
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = { for k, v in var.security_group_egress_rules : k => v if var.security_group_egress_rules != null && local.create_security_group }

  region = var.region

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = try(coalesce(each.value.from_port, each.value.to_port), null)
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id == "self" ? aws_security_group.this[0].id : each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  tags = merge(
    var.tags,
    var.security_group_tags,
    { "Name" = coalesce(each.value.name, "${local.security_group_name}-${each.key}") },
    each.value.tags
  )
  to_port = each.value.to_port
}
