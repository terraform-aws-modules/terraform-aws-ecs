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

resource "aws_ecs_cluster_capacity_providers" "this" {
  count = var.create ? 1 : 0

  region = var.region

  cluster_name = aws_ecs_cluster.this[0].name
  capacity_providers = distinct(concat(
    [for k, v in var.default_capacity_provider_strategy : try(coalesce(v.name, k))],
    var.autoscaling_capacity_providers != null ? [for k, v in var.autoscaling_capacity_providers : try(coalesce(v.name, k))] : []
  ))

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-capacity-providers.html#capacity-providers-considerations
  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy != null ? var.default_capacity_provider_strategy : {}

    content {
      base              = default_capacity_provider_strategy.value.base
      capacity_provider = try(coalesce(default_capacity_provider_strategy.value.name, default_capacity_provider_strategy.key))
      weight            = default_capacity_provider_strategy.value.weight
    }
  }

  depends_on = [
    aws_ecs_capacity_provider.this
  ]
}

################################################################################
# Capacity Provider - Autoscaling Group(s)
################################################################################

resource "aws_ecs_capacity_provider" "this" {
  for_each = var.create && var.autoscaling_capacity_providers != null ? var.autoscaling_capacity_providers : {}

  region = var.region

  auto_scaling_group_provider {
    auto_scaling_group_arn = each.value.auto_scaling_group_arn
    managed_draining       = each.value.managed_draining

    dynamic "managed_scaling" {
      for_each = each.value.managed_scaling != null ? [each.value.managed_scaling] : []

      content {
        instance_warmup_period    = managed_scaling.value.instance_warmup_period
        maximum_scaling_step_size = managed_scaling.value.maximum_scaling_step_size
        minimum_scaling_step_size = managed_scaling.value.minimum_scaling_step_size
        status                    = managed_scaling.value.status
        target_capacity           = managed_scaling.value.target_capacity
      }
    }

    # When you use managed termination protection, you must also use managed scaling otherwise managed termination protection won't work
    managed_termination_protection = each.value.managed_scaling != null ? each.value.managed_termination_protection : "DISABLED"
  }

  name = try(coalesce(each.value.name, each.key), "")

  tags = merge(
    var.tags,
    each.value.tags,
  )
}

################################################################################
# Task Execution - IAM Role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
################################################################################

locals {
  task_exec_iam_role_name = try(coalesce(var.task_exec_iam_role_name, var.name), "")

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
