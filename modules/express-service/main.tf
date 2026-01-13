data "aws_partition" "current" {
  count = var.create ? 1 : 0
}

data "aws_region" "current" {
  region = var.region

  count = var.create ? 1 : 0
}

locals {
  partition = try(data.aws_partition.current[0].partition, "")
  region    = try(data.aws_region.current[0].region, "")
}

################################################################################
# Express Service
################################################################################

resource "aws_ecs_express_gateway_service" "this" {
  count = var.create ? 1 : 0

  region = var.region

  cluster                 = var.cluster
  cpu                     = var.cpu
  execution_role_arn      = local.create_execution_iam_role ? aws_iam_role.execution[0].arn : var.execution_iam_role_arn
  health_check_path       = var.health_check_path
  infrastructure_role_arn = local.create_infrastructure_iam_role ? aws_iam_role.infrastructure[0].arn : var.infrastructure_iam_role_arn
  memory                  = var.memory

  dynamic "network_configuration" {
    for_each = var.network_configuration != null ? [var.network_configuration] : []

    content {
      security_groups = concat(aws_security_group.this[*].id, network_configuration.value.security_groups)
      subnets         = network_configuration.value.subnets
    }
  }

  dynamic "primary_container" {
    for_each = var.primary_container != null ? [var.primary_container] : []

    content {
      dynamic "aws_logs_configuration" {
        for_each = primary_container.value.aws_logs_configuration != null ? [primary_container.value.aws_logs_configuration] : []

        content {
          log_group         = aws_logs_configuration.value.log_group
          log_stream_prefix = aws_logs_configuration.value.log_stream_prefix
        }
      }

      command        = primary_container.value.command
      container_port = primary_container.value.container_port

      dynamic "environment" {
        for_each = primary_container.value.environment != null ? primary_container.value.environment : []

        content {
          name  = environment.value.name
          value = environment.value.value
        }
      }

      image = primary_container.value.image

      dynamic "repository_credentials" {
        for_each = primary_container.value.repository_credentials != null ? [primary_container.value.repository_credentials] : []

        content {
          credentials_parameter = repository_credentials.value.credentials_parameter
        }
      }

      dynamic "secret" {
        for_each = primary_container.value.secret != null ? primary_container.value.secret : []

        content {
          name       = secret.value.name
          value_from = secret.value.value_from
        }
      }
    }
  }

  dynamic "scaling_target" {
    for_each = var.scaling_target != null ? [var.scaling_target] : []

    content {
      auto_scaling_metric       = scaling_target.value.auto_scaling_metric
      auto_scaling_target_value = scaling_target.value.auto_scaling_target_value
      max_task_count            = scaling_target.value.max_task_count
      min_task_count            = scaling_target.value.min_task_count
    }
  }

  service_name  = var.name
  task_role_arn = local.create_task_iam_role ? aws_iam_role.task[0].arn : var.task_iam_role_arn

  tags = var.tags
}

################################################################################
# Security Group
################################################################################

locals {
  create_security_group = var.create && var.create_security_group
  security_group_name   = try(coalesce(var.security_group_name, var.name), "")
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  region = var.region

  name        = var.security_group_use_name_prefix ? null : local.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.security_group_name}-" : null
  description = try(coalesce(var.security_group_description, "Security group for ECS Express Service ${var.name}"))
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    { "Name" = local.security_group_name },
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

################################################################################
# Execution IAM Role
################################################################################

locals {
  create_execution_iam_role = var.create && var.create_execution_iam_role
  execution_iam_role_name   = coalesce(var.execution_iam_role_name, "${var.name}-exec")
}

data "aws_iam_policy_document" "execution_assume" {
  count = local.create_execution_iam_role ? 1 : 0

  statement {
    sid     = "ECSTaskExecutionAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  count = local.create_execution_iam_role ? 1 : 0

  name        = var.execution_iam_role_use_name_prefix ? null : local.execution_iam_role_name
  name_prefix = var.execution_iam_role_use_name_prefix ? "${local.execution_iam_role_name}-" : null
  path        = var.execution_iam_role_path
  description = coalesce(var.execution_iam_role_description, "Execution role IAM policy for ECS Express Service ${var.name}")

  assume_role_policy    = data.aws_iam_policy_document.execution_assume[0].json
  max_session_duration  = var.execution_iam_role_max_session_duration
  permissions_boundary  = var.execution_iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.execution_iam_role_tags)
}

################################################################################
# Execution IAM Policy
################################################################################

locals {
  create_execution_policy = local.create_execution_iam_role && var.create_execution_policy
}

data "aws_iam_policy_document" "execution" {
  count = local.create_execution_policy ? 1 : 0

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
    for_each = length(var.execution_ssm_param_arns) > 0 ? [1] : []

    content {
      sid       = "GetSSMParams"
      actions   = ["ssm:GetParameters"]
      resources = var.execution_ssm_param_arns
    }
  }

  dynamic "statement" {
    for_each = length(var.execution_secret_arns) > 0 ? [1] : []

    content {
      sid       = "GetSecrets"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = var.execution_secret_arns
    }
  }

  dynamic "statement" {
    for_each = var.execution_iam_statements != null ? var.execution_iam_statements : {}

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

resource "aws_iam_policy" "execution" {
  count = local.create_execution_policy ? 1 : 0

  name        = var.execution_iam_role_use_name_prefix ? null : local.execution_iam_role_name
  name_prefix = var.execution_iam_role_use_name_prefix ? "${local.execution_iam_role_name}-" : null
  description = coalesce(var.execution_iam_role_description, "Execution role IAM policy for ECS Express Service ${var.name}")
  policy      = data.aws_iam_policy_document.execution[0].json
  path        = var.execution_iam_policy_path

  tags = merge(var.tags, var.execution_iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "execution" {
  count = local.create_execution_policy ? 1 : 0

  role       = aws_iam_role.execution[0].name
  policy_arn = aws_iam_policy.execution[0].arn
}

resource "aws_iam_role_policy_attachment" "execution_additional" {
  for_each = { for k, v in var.execution_iam_role_policies : k => v if local.create_execution_iam_role }

  role       = aws_iam_role.execution[0].name
  policy_arn = each.value
}

############################################################################################
# Infrastructure IAM Role
############################################################################################

locals {
  create_infrastructure_iam_role = var.create && var.create_infrastructure_iam_role
  infrastructure_iam_role_name   = coalesce(var.infrastructure_iam_role_name, "${var.name}-infra")
}

data "aws_iam_policy_document" "infrastructure_assume" {
  count = local.create_infrastructure_iam_role ? 1 : 0

  statement {
    sid     = "InfrastructureForECSExpressServices"
    actions = ["sts:AssumeRole"]

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
  description = coalesce(var.infrastructure_iam_role_description, "Infrastructure role IAM policy for ECS Express Service ${var.name}")

  assume_role_policy    = data.aws_iam_policy_document.infrastructure_assume[0].json
  permissions_boundary  = var.infrastructure_iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.infrastructure_iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "infrastructure" {
  count = local.create_infrastructure_iam_role ? 1 : 0

  role       = aws_iam_role.infrastructure[0].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AmazonECSInfrastructureRoleforExpressGatewayServices"
}

################################################################################
# Task IAM Role
################################################################################

locals {
  task_iam_role_name   = coalesce(var.task_iam_role_name, "${var.name}-task")
  create_task_iam_role = var.create && var.create_task_iam_role
}

data "aws_iam_policy_document" "task_assume" {
  count = local.create_task_iam_role ? 1 : 0

  statement {
    sid     = "TasksForECSExpressServices"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task" {
  count = local.create_task_iam_role ? 1 : 0

  name        = var.task_iam_role_use_name_prefix ? null : local.task_iam_role_name
  name_prefix = var.task_iam_role_use_name_prefix ? "${local.task_iam_role_name}-" : null
  path        = var.task_iam_role_path
  description = try(coalesce(var.task_iam_role_description, "Task role IAM policy for ECS Express Service ${var.name}"))

  assume_role_policy    = data.aws_iam_policy_document.task_assume[0].json
  max_session_duration  = var.task_iam_role_max_session_duration
  permissions_boundary  = var.task_iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.task_iam_role_tags)
}

################################################################################
# Task IAM Policy
################################################################################

locals {
  create_task_policy = local.create_task_iam_role && var.task_iam_role_statements != null
}

data "aws_iam_policy_document" "task" {
  count = local.create_task_policy ? 1 : 0

  dynamic "statement" {
    for_each = var.task_iam_role_statements != null ? var.task_iam_role_statements : {}

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

resource "aws_iam_policy" "task" {
  count = local.create_task_policy ? 1 : 0

  name        = var.task_iam_role_use_name_prefix ? null : local.task_iam_role_name
  name_prefix = var.task_iam_role_use_name_prefix ? "${local.task_iam_role_name}-" : null
  description = coalesce(var.task_iam_role_description, "Task role IAM policy for ECS Express Service ${var.name}")
  policy      = data.aws_iam_policy_document.task[0].json
  path        = var.task_iam_role_path

  tags = merge(var.tags, var.task_iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "task" {
  count = local.create_task_policy ? 1 : 0

  role       = aws_iam_role.task[0].name
  policy_arn = aws_iam_policy.task[0].arn
}

resource "aws_iam_role_policy_attachment" "task_additional" {
  for_each = { for k, v in var.task_iam_role_policies : k => v if local.create_task_iam_role }

  role       = aws_iam_role.task[0].name
  policy_arn = each.value
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
