################################################################################
# Cluster
################################################################################

resource "aws_ecs_cluster" "this" {
  count = var.create ? 1 : 0

  name = var.cluster_name

  dynamic "configuration" {
    for_each = try([var.cluster_configuration], [])

    content {
      dynamic "execute_command_configuration" {
        for_each = try([configuration.value.execute_command_configuration], [])

        content {
          kms_key_id = try(execute_command_configuration.value.kms_key_id, null)
          logging    = try(execute_command_configuration.value.logging, "DEFAULT")

          dynamic "log_configuration" {
            for_each = try([execute_command_configuration.value.log_configuration], [])

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
# Cluster Capacity Providers
################################################################################

locals {
  # We are merging these together so that we can reference the ECS capacity provider
  # (ec2 autoscaling) created in this module below. Fargate is easy since its just
  # a static string, but the ECs cappacity provider needs to be self-referenced from
  # within this module. Therefore the input schema of `var.cluster_capacity_providers`
  # is customized to allow for both routes
  cluster_capacity_providers = merge(
    var.cluster_capacity_providers,
    { for k, v in var.capacity_providers : k => merge(aws_ecs_capacity_provider.this[k], v) }
  )
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  count = var.create ? 1 : 0

  cluster_name = aws_ecs_cluster.this[0].name
  capacity_providers = distinct(concat(
    [for k, v in var.cluster_capacity_providers : try(v.name, k)],
    [for k, v in var.capacity_providers : try(v.name, k)]
  ))

  dynamic "default_capacity_provider_strategy" {
    for_each = local.cluster_capacity_providers

    content {
      capacity_provider = try(default_capacity_provider_strategy.value.name, default_capacity_provider_strategy.key)
      base              = try(default_capacity_provider_strategy.value.default_capacity_provider_strategy.base, null)
      weight            = try(default_capacity_provider_strategy.value.default_capacity_provider_strategy.weight, null)
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
