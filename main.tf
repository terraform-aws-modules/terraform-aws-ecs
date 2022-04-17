resource "aws_ecs_cluster" "this" {
  count = var.create_ecs ? 1 : 0

  name = var.name

  setting {
    name  = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = var.configuration.kms_key_id
      logging    = var.configuration.logging

      dynamic "log_configuration" {
        for_each = var.configuration.logging == "OVERRIDE" ? [var.configuration] : []
        content {
          cloud_watch_encryption_enabled = log_configuration.value.cloud_watch_encryption_enabled
          cloud_watch_log_group_name     = log_configuration.value.cloud_watch_log_group_name
          s3_bucket_name                 = log_configuration.value.s3_bucket_name
          s3_bucket_encryption_enabled   = log_configuration.value.s3_bucket_encryption_enabled
          s3_key_prefix                  = log_configuration.value.s3_key_prefix
        }
      }
    }

  }

  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  count = var.create_ecs ? 1 : 0

  cluster_name = aws_ecs_cluster.this[0].name

  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    iterator = strategy

    content {
      capacity_provider = strategy.value["capacity_provider"]
      weight            = lookup(strategy.value, "weight", null)
      base              = lookup(strategy.value, "base", null)
    }
  }
}
