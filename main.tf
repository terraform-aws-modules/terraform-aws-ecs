################################################################################
# Cluster
################################################################################

locals {
  # Used to default to logs enabled and sent to cloudwatch group created by module
  cluster_configuration = merge(
    {
      execute_command_configuration = {
        log_configuration = {
          cloud_watch_log_group_name = var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.this[0].name : null
        }
      }
    },
    var.cluster_configuration,
  )
}

resource "aws_ecs_cluster" "this" {
  count = var.create ? 1 : 0

  name = var.cluster_name


  dynamic "configuration" {
    for_each = [local.cluster_configuration]

    content {
      dynamic "execute_command_configuration" {
        for_each = [configuration.value.execute_command_configuration]

        content {
          kms_key_id = try(execute_command_configuration.value.kms_key_id, null)
          logging    = try(execute_command_configuration.value.logging, "DEFAULT")

          dynamic "log_configuration" {
            for_each = [execute_command_configuration.value.log_configuration]

            content {
              cloud_watch_encryption_enabled = try(log_configuration.value.cloud_watch_encryption_enabled, null)
              cloud_watch_log_group_name     = try(log_configuration.value.cloud_watch_log_group_name, null)
              s3_bucket_name                 = try(log_configuration.value.s3_bucket_name, null)
              s3_bucket_encryption_enabled   = try(log_configuration.value.s3_bucket_encryption_enabled, null)
              s3_key_prefix                  = try(log_configuration.value.s3_key_prefix, null)
            }
          }
        }
      }
    }
  }

  dynamic "setting" {
    for_each = length(var.cluster_settings) > 0 ? [var.cluster_settings] : []

    content {
      name  = try(setting.value.name, "containerInsights")
      value = setting.value.value
    }
  }

  tags = var.tags
}

################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  count = var.create && var.create_cloudwatch_log_group ? 1 : 0

  name              = coalesce(var.cloudwatch_log_group_name, "/aws/ecs/${var.cluster_name}")
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = var.tags
}

################################################################################
# Cluster Capacity Providers - Fargate
################################################################################

resource "aws_ecs_cluster_capacity_providers" "this" {
  count = var.create ? 1 : 0

  cluster_name       = aws_ecs_cluster.this[0].name
  capacity_providers = var.cluster_capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.cluster_default_capacity_provider_strategy

    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      base              = try(default_capacity_provider_strategy.value.base, null)
      weight            = try(default_capacity_provider_strategy.value.weight, null)
    }
  }
}

################################################################################
# Capacity Provider - Autoscaling Group(s)
################################################################################

resource "aws_ecs_capacity_provider" "this" {
  for_each = { for k, v in var.capacity_providers : k => v if var.create }

  name = try(each.value.name, each.key)

  auto_scaling_group_provider {
    auto_scaling_group_arn         = each.value.auto_scaling_group_arn
    managed_termination_protection = each.value.managed_termination_protection

    dynamic "managed_scaling" {
      for_each = try([each.value.managed_scaling], [])

      content {
        instance_warmup_period    = try(managed_scaling.value.instance_warmup_period, null)
        maximum_scaling_step_size = try(managed_scaling.value.maximum_scaling_step_size, null)
        minimum_scaling_step_size = try(managed_scaling.value.minimum_scaling_step_size, null)
        status                    = try(managed_scaling.value.status, null)
        target_capacity           = try(managed_scaling.value.target_capacity, null)
      }
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}
