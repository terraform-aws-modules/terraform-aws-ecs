data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name
}

################################################################################
# Service
################################################################################

locals {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/deployment-type-external.html
  is_external_deployment = try(var.deployment_controller.type, null) == "EXTERNAL"
  is_daemon              = var.scheduling_strategy == "DAEMON"
  is_fargate             = var.launch_type == "FARGATE"

  # Flattened `network_configuration`
  network_configuration = {
    assign_public_ip = var.assign_public_ip
    security_groups  = flatten(concat([try(aws_security_group.this[0].id, [])], var.security_group_ids))
    subnets          = var.subnet_ids
  }

  create_service = var.create && var.create_service
}

resource "aws_ecs_service" "this" {
  count = local.create_service && !var.ignore_task_definition_changes ? 1 : 0

  dynamic "alarms" {
    for_each = length(var.alarms) > 0 ? [var.alarms] : []

    content {
      alarm_names = alarms.value.alarm_names
      enable      = try(alarms.value.enable, true)
      rollback    = try(alarms.value.rollback, true)
    }
  }

  dynamic "capacity_provider_strategy" {
    # Set by task set if deployment controller is external
    for_each = { for k, v in var.capacity_provider_strategy : k => v if !local.is_external_deployment }

    content {
      base              = try(capacity_provider_strategy.value.base, null)
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = try(capacity_provider_strategy.value.weight, null)
    }
  }

  cluster = var.cluster_arn

  dynamic "deployment_circuit_breaker" {
    for_each = length(var.deployment_circuit_breaker) > 0 ? [var.deployment_circuit_breaker] : []

    content {
      enable   = deployment_circuit_breaker.value.enable
      rollback = deployment_circuit_breaker.value.rollback
    }
  }

  dynamic "deployment_controller" {
    for_each = length(var.deployment_controller) > 0 ? [var.deployment_controller] : []

    content {
      type = try(deployment_controller.value.type, null)
    }
  }

  deployment_maximum_percent         = local.is_daemon || local.is_external_deployment ? null : var.deployment_maximum_percent
  deployment_minimum_healthy_percent = local.is_daemon || local.is_external_deployment ? null : var.deployment_minimum_healthy_percent
  desired_count                      = local.is_daemon || local.is_external_deployment ? null : var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  enable_execute_command             = var.enable_execute_command
  force_new_deployment               = local.is_external_deployment ? null : var.force_new_deployment
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  iam_role                           = local.iam_role_arn
  launch_type                        = local.is_external_deployment || length(var.capacity_provider_strategy) > 0 ? null : var.launch_type

  dynamic "load_balancer" {
    # Set by task set if deployment controller is external
    for_each = { for k, v in var.load_balancer : k => v if !local.is_external_deployment }

    content {
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
      elb_name         = try(load_balancer.value.elb_name, null)
      target_group_arn = try(load_balancer.value.target_group_arn, null)
    }
  }

  name = var.name

  dynamic "network_configuration" {
    # Set by task set if deployment controller is external
    for_each = var.network_mode == "awsvpc" && !local.is_external_deployment ? [local.network_configuration] : []

    content {
      assign_public_ip = network_configuration.value.assign_public_ip
      security_groups  = network_configuration.value.security_groups
      subnets          = network_configuration.value.subnets
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy

    content {
      field = try(ordered_placement_strategy.value.field, null)
      type  = ordered_placement_strategy.value.type
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints

    content {
      expression = try(placement_constraints.value.expression, null)
      type       = placement_constraints.value.type
    }
  }

  # Set by task set if deployment controller is external
  platform_version    = local.is_fargate && !local.is_external_deployment ? var.platform_version : null
  scheduling_strategy = local.is_fargate ? "REPLICA" : var.scheduling_strategy

  dynamic "service_connect_configuration" {
    for_each = length(var.service_connect_configuration) > 0 ? [var.service_connect_configuration] : []

    content {
      enabled = try(service_connect_configuration.value.enabled, true)

      dynamic "log_configuration" {
        for_each = try([service_connect_configuration.value.log_configuration], [])

        content {
          log_driver = try(log_configuration.value.log_driver, null)
          options    = try(log_configuration.value.options, null)

          dynamic "secret_option" {
            for_each = try(log_configuration.value.secret_option, [])

            content {
              name       = secret_option.value.name
              value_from = secret_option.value.value_from
            }
          }
        }
      }

      namespace = lookup(service_connect_configuration.value, "namespace", null)

      dynamic "service" {
        for_each = try([service_connect_configuration.value.service], [])

        content {

          dynamic "client_alias" {
            for_each = try([service.value.client_alias], [])

            content {
              dns_name = try(client_alias.value.dns_name, null)
              port     = client_alias.value.port
            }
          }

          discovery_name        = try(service.value.discovery_name, null)
          ingress_port_override = try(service.value.ingress_port_override, null)
          port_name             = service.value.port_name
        }
      }
    }
  }

  dynamic "service_registries" {
    # Set by task set if deployment controller is external
    for_each = length(var.service_registries) > 0 ? [{ for k, v in var.service_registries : k => v if !local.is_external_deployment }] : []

    content {
      container_name = try(service_registries.value.container_name, null)
      container_port = try(service_registries.value.container_port, null)
      port           = try(service_registries.value.port, null)
      registry_arn   = service_registries.value.registry_arn
    }
  }

  task_definition       = local.task_definition
  triggers              = var.triggers
  wait_for_steady_state = var.wait_for_steady_state

  propagate_tags = var.propagate_tags
  tags           = merge(var.tags, var.service_tags)

  timeouts {
    create = try(var.timeouts.create, null)
    update = try(var.timeouts.update, null)
    delete = try(var.timeouts.delete, null)
  }

  depends_on = [
    aws_iam_role_policy_attachment.service
  ]

  lifecycle {
    ignore_changes = [
      desired_count, # Always ignored
    ]
  }
}

################################################################################
# Service - Ignore `task_definition`
################################################################################

resource "aws_ecs_service" "ignore_task_definition" {
  count = local.create_service && var.ignore_task_definition_changes ? 1 : 0

  dynamic "alarms" {
    for_each = length(var.alarms) > 0 ? [var.alarms] : []

    content {
      alarm_names = alarms.value.alarm_names
      enable      = try(alarms.value.enable, true)
      rollback    = try(alarms.value.rollback, true)
    }
  }

  dynamic "capacity_provider_strategy" {
    # Set by task set if deployment controller is external
    for_each = { for k, v in var.capacity_provider_strategy : k => v if !local.is_external_deployment }

    content {
      base              = try(capacity_provider_strategy.value.base, null)
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = try(capacity_provider_strategy.value.weight, null)
    }
  }

  cluster = var.cluster_arn

  dynamic "deployment_circuit_breaker" {
    for_each = length(var.deployment_circuit_breaker) > 0 ? [var.deployment_circuit_breaker] : []

    content {
      enable   = deployment_circuit_breaker.value.enable
      rollback = deployment_circuit_breaker.value.rollback
    }
  }

  dynamic "deployment_controller" {
    for_each = length(var.deployment_controller) > 0 ? [var.deployment_controller] : []

    content {
      type = try(deployment_controller.value.type, null)
    }
  }

  deployment_maximum_percent         = local.is_daemon || local.is_external_deployment ? null : var.deployment_maximum_percent
  deployment_minimum_healthy_percent = local.is_daemon || local.is_external_deployment ? null : var.deployment_minimum_healthy_percent
  desired_count                      = local.is_daemon || local.is_external_deployment ? null : var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  enable_execute_command             = var.enable_execute_command
  force_new_deployment               = local.is_external_deployment ? null : var.force_new_deployment
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  iam_role                           = local.iam_role_arn
  launch_type                        = local.is_external_deployment || length(var.capacity_provider_strategy) > 0 ? null : var.launch_type

  dynamic "load_balancer" {
    # Set by task set if deployment controller is external
    for_each = { for k, v in var.load_balancer : k => v if !local.is_external_deployment }

    content {
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
      elb_name         = try(load_balancer.value.elb_name, null)
      target_group_arn = try(load_balancer.value.target_group_arn, null)
    }
  }

  name = var.name

  dynamic "network_configuration" {
    # Set by task set if deployment controller is external
    for_each = var.network_mode == "awsvpc" ? [{ for k, v in local.network_configuration : k => v if !local.is_external_deployment }] : []

    content {
      assign_public_ip = network_configuration.value.assign_public_ip
      security_groups  = network_configuration.value.security_groups
      subnets          = network_configuration.value.subnets
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy

    content {
      field = try(ordered_placement_strategy.value.field, null)
      type  = ordered_placement_strategy.value.type
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints

    content {
      expression = try(placement_constraints.value.expression, null)
      type       = placement_constraints.value.type
    }
  }

  # Set by task set if deployment controller is external
  platform_version    = local.is_fargate && !local.is_external_deployment ? var.platform_version : null
  scheduling_strategy = local.is_fargate ? "REPLICA" : var.scheduling_strategy

  dynamic "service_connect_configuration" {
    for_each = length(var.service_connect_configuration) > 0 ? [var.service_connect_configuration] : []

    content {
      enabled = try(service_connect_configuration.value.enabled, true)

      dynamic "log_configuration" {
        for_each = try([service_connect_configuration.value.log_configuration], [])

        content {
          log_driver = try(log_configuration.value.log_driver, null)
          options    = try(log_configuration.value.options, null)

          dynamic "secret_option" {
            for_each = try(log_configuration.value.secret_option, [])

            content {
              name       = secret_option.value.name
              value_from = secret_option.value.value_from
            }
          }
        }
      }

      namespace = lookup(service_connect_configuration.value, "namespace", null)

      dynamic "service" {
        for_each = try([service_connect_configuration.value.service], [])

        content {

          dynamic "client_alias" {
            for_each = try([service.value.client_alias], [])

            content {
              dns_name = try(client_alias.value.dns_name, null)
              port     = client_alias.value.port
            }
          }

          discovery_name        = try(service.value.discovery_name, null)
          ingress_port_override = try(service.value.ingress_port_override, null)
          port_name             = service.value.port_name
        }
      }
    }
  }

  dynamic "service_registries" {
    # Set by task set if deployment controller is external
    for_each = length(var.service_registries) > 0 ? [{ for k, v in var.service_registries : k => v if !local.is_external_deployment }] : []

    content {
      container_name = try(service_registries.value.container_name, null)
      container_port = try(service_registries.value.container_port, null)
      port           = try(service_registries.value.port, null)
      registry_arn   = service_registries.value.registry_arn
    }
  }

  task_definition       = local.task_definition
  triggers              = var.triggers
  wait_for_steady_state = var.wait_for_steady_state

  propagate_tags = var.propagate_tags
  tags           = var.tags

  timeouts {
    create = try(var.timeouts.create, null)
    update = try(var.timeouts.update, null)
    delete = try(var.timeouts.delete, null)
  }

  depends_on = [
    aws_iam_role_policy_attachment.service
  ]

  lifecycle {
    ignore_changes = [
      desired_count, # Always ignored
      task_definition,
      load_balancer,
    ]
  }
}

################################################################################
# Service - IAM Role
################################################################################

locals {
  # Role is not required if task definition uses `awsvpc` network mode or if a load balancer is not used
  needs_iam_role  = var.network_mode != "awsvpc" && length(var.load_balancer) > 0
  create_iam_role = var.create && var.create_iam_role && local.needs_iam_role
  iam_role_arn    = local.needs_iam_role ? try(aws_iam_role.service[0].arn, var.iam_role_arn) : null

  iam_role_name = try(coalesce(var.iam_role_name, var.name), "")
}

data "aws_iam_policy_document" "service_assume" {
  count = local.create_iam_role ? 1 : 0

  statement {
    sid     = "ECSServiceAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "service" {
  count = local.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.service_assume[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.iam_role_tags)
}

data "aws_iam_policy_document" "service" {
  count = local.create_iam_role ? 1 : 0

  statement {
    sid       = "ECSService"
    resources = ["*"]

    actions = [
      "ec2:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets"
    ]
  }

  dynamic "statement" {
    for_each = var.iam_role_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_policy" "service" {
  count = local.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  description = coalesce(var.iam_role_description, "ECS service policy that allows Amazon ECS to make calls to your load balancer on your behalf")
  policy      = data.aws_iam_policy_document.service[0].json

  tags = merge(var.tags, var.iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "service" {
  count = local.create_iam_role ? 1 : 0

  role       = aws_iam_role.service[0].name
  policy_arn = aws_iam_policy.service[0].arn
}

################################################################################
# Container Definition
################################################################################

module "container_definition" {
  source = "../container-definition"

  for_each = { for k, v in var.container_definitions : k => v if local.create_task_definition && try(v.create, true) }

  operating_system_family = try(var.runtime_platform.operating_system_family, "LINUX")

  # Container Definition
  command                  = try(each.value.command, var.container_definition_defaults.command, [])
  cpu                      = try(each.value.cpu, var.container_definition_defaults.cpu, null)
  dependencies             = try(each.value.dependencies, var.container_definition_defaults.dependencies, []) # depends_on is a reserved word
  disable_networking       = try(each.value.disable_networking, var.container_definition_defaults.disable_networking, null)
  dns_search_domains       = try(each.value.dns_search_domains, var.container_definition_defaults.dns_search_domains, [])
  dns_servers              = try(each.value.dns_servers, var.container_definition_defaults.dns_servers, [])
  docker_labels            = try(each.value.docker_labels, var.container_definition_defaults.docker_labels, {})
  docker_security_options  = try(each.value.docker_security_options, var.container_definition_defaults.docker_security_options, [])
  enable_execute_command   = try(each.value.enable_execute_command, var.container_definition_defaults.enable_execute_command, var.enable_execute_command)
  entrypoint               = try(each.value.entrypoint, var.container_definition_defaults.entrypoint, [])
  environment              = try(each.value.environment, var.container_definition_defaults.environment, [])
  environment_files        = try(each.value.environment_files, var.container_definition_defaults.environment_files, [])
  essential                = try(each.value.essential, var.container_definition_defaults.essential, null)
  extra_hosts              = try(each.value.extra_hosts, var.container_definition_defaults.extra_hosts, [])
  firelens_configuration   = try(each.value.firelens_configuration, var.container_definition_defaults.firelens_configuration, {})
  health_check             = try(each.value.health_check, var.container_definition_defaults.health_check, {})
  hostname                 = try(each.value.hostname, var.container_definition_defaults.hostname, null)
  image                    = try(each.value.image, var.container_definition_defaults.image, null)
  interactive              = try(each.value.interactive, var.container_definition_defaults.interactive, false)
  links                    = try(each.value.links, var.container_definition_defaults.links, [])
  linux_parameters         = try(each.value.linux_parameters, var.container_definition_defaults.linux_parameters, {})
  log_configuration        = try(each.value.log_configuration, var.container_definition_defaults.log_configuration, {})
  memory                   = try(each.value.memory, var.container_definition_defaults.memory, null)
  memory_reservation       = try(each.value.memory_reservation, var.container_definition_defaults.memory_reservation, null)
  mount_points             = try(each.value.mount_points, var.container_definition_defaults.mount_points, [])
  name                     = try(each.value.name, each.key)
  port_mappings            = try(each.value.port_mappings, var.container_definition_defaults.port_mappings, [])
  privileged               = try(each.value.privileged, var.container_definition_defaults.privileged, false)
  pseudo_terminal          = try(each.value.pseudo_terminal, var.container_definition_defaults.pseudo_terminal, false)
  readonly_root_filesystem = try(each.value.readonly_root_filesystem, var.container_definition_defaults.readonly_root_filesystem, true)
  repository_credentials   = try(each.value.repository_credentials, var.container_definition_defaults.repository_credentials, {})
  resource_requirements    = try(each.value.resource_requirements, var.container_definition_defaults.resource_requirements, [])
  secrets                  = try(each.value.secrets, var.container_definition_defaults.secrets, [])
  start_timeout            = try(each.value.start_timeout, var.container_definition_defaults.start_timeout, 30)
  stop_timeout             = try(each.value.stop_timeout, var.container_definition_defaults.stop_timeout, 120)
  system_controls          = try(each.value.system_controls, var.container_definition_defaults.system_controls, [])
  ulimits                  = try(each.value.ulimits, var.container_definition_defaults.ulimits, [])
  user                     = try(each.value.user, var.container_definition_defaults.user, 0)
  volumes_from             = try(each.value.volumes_from, var.container_definition_defaults.volumes_from, [])
  working_directory        = try(each.value.working_directory, var.container_definition_defaults.working_directory, null)

  # CloudWatch Log Group
  service                                = var.name
  enable_cloudwatch_logging              = try(each.value.enable_cloudwatch_logging, var.container_definition_defaults.enable_cloudwatch_logging, true)
  create_cloudwatch_log_group            = try(each.value.create_cloudwatch_log_group, var.container_definition_defaults.create_cloudwatch_log_group, true)
  cloudwatch_log_group_name              = try(each.value.cloudwatch_log_group_name, var.container_definition_defaults.cloudwatch_log_group_name, null)
  cloudwatch_log_group_use_name_prefix   = try(each.value.cloudwatch_log_group_use_name_prefix, var.container_definition_defaults.cloudwatch_log_group_use_name_prefix, false)
  cloudwatch_log_group_retention_in_days = try(each.value.cloudwatch_log_group_retention_in_days, var.container_definition_defaults.cloudwatch_log_group_retention_in_days, 14)
  cloudwatch_log_group_kms_key_id        = try(each.value.cloudwatch_log_group_kms_key_id, var.container_definition_defaults.cloudwatch_log_group_kms_key_id, null)

  tags = var.tags
}

################################################################################
# Task Definition
################################################################################

locals {
  create_task_definition = var.create && var.create_task_definition

  # This allows us to query both the existing as well as Terraform's state and get
  # and get the max version of either source, useful for when external resources
  # update the container definition
  max_task_def_revision = local.create_task_definition ? max(aws_ecs_task_definition.this[0].revision, data.aws_ecs_task_definition.this[0].revision) : 0
  task_definition       = local.create_task_definition ? "${aws_ecs_task_definition.this[0].family}:${local.max_task_def_revision}" : var.task_definition_arn
}

# This allows us to query both the existing as well as Terraform's state and get
# and get the max version of either source, useful for when external resources
# update the container definition
data "aws_ecs_task_definition" "this" {
  count = local.create_task_definition ? 1 : 0

  task_definition = aws_ecs_task_definition.this[0].family

  depends_on = [
    # Needs to exist first on first deployment
    aws_ecs_task_definition.this
  ]
}

resource "aws_ecs_task_definition" "this" {
  count = local.create_task_definition ? 1 : 0

  # Convert map of maps to array of maps before JSON encoding
  container_definitions = jsonencode([for k, v in module.container_definition : v.container_definition])
  cpu                   = var.cpu

  dynamic "ephemeral_storage" {
    for_each = length(var.ephemeral_storage) > 0 ? [var.ephemeral_storage] : []

    content {
      size_in_gib = ephemeral_storage.value.size_in_gib
    }
  }

  execution_role_arn = try(aws_iam_role.task_exec[0].arn, var.task_exec_iam_role_arn)
  family             = coalesce(var.family, var.name)

  dynamic "inference_accelerator" {
    for_each = var.inference_accelerator

    content {
      device_name = inference_accelerator.value.device_name
      device_type = inference_accelerator.value.device_type
    }
  }

  ipc_mode     = var.ipc_mode
  memory       = var.memory
  network_mode = var.network_mode
  pid_mode     = var.pid_mode

  dynamic "placement_constraints" {
    for_each = var.task_definition_placement_constraints

    content {
      expression = try(placement_constraints.value.expression, null)
      type       = placement_constraints.value.type
    }
  }

  dynamic "proxy_configuration" {
    for_each = length(var.proxy_configuration) > 0 ? [var.proxy_configuration] : []

    content {
      container_name = proxy_configuration.value.container_name
      properties     = try(proxy_configuration.value.properties, null)
      type           = try(proxy_configuration.value.type, null)
    }
  }

  requires_compatibilities = var.requires_compatibilities

  dynamic "runtime_platform" {
    for_each = length(var.runtime_platform) > 0 ? [var.runtime_platform] : []

    content {
      cpu_architecture        = try(runtime_platform.value.cpu_architecture, null)
      operating_system_family = try(runtime_platform.value.operating_system_family, null)
    }
  }

  skip_destroy  = var.skip_destroy
  task_role_arn = try(aws_iam_role.tasks[0].arn, var.tasks_iam_role_arn)

  dynamic "volume" {
    for_each = var.volume

    content {
      dynamic "docker_volume_configuration" {
        for_each = try([volume.value.docker_volume_configuration], [])

        content {
          autoprovision = try(docker_volume_configuration.value.autoprovision, null)
          driver        = try(docker_volume_configuration.value.driver, null)
          driver_opts   = try(docker_volume_configuration.value.driver_opts, null)
          labels        = try(docker_volume_configuration.value.labels, null)
          scope         = try(docker_volume_configuration.value.scope, null)
        }
      }

      dynamic "efs_volume_configuration" {
        for_each = try([volume.value.efs_volume_configuration], [])

        content {
          dynamic "authorization_config" {
            for_each = try([efs_volume_configuration.value.authorization_config], [])

            content {
              access_point_id = try(authorization_config.value.access_point_id, null)
              iam             = try(authorization_config.value.iam, null)
            }
          }

          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = try(efs_volume_configuration.value.root_directory, null)
          transit_encryption      = try(efs_volume_configuration.value.transit_encryption, null)
          transit_encryption_port = try(efs_volume_configuration.value.transit_encryption_port, null)
        }
      }

      dynamic "fsx_windows_file_server_volume_configuration" {
        for_each = try([volume.value.fsx_windows_file_server_volume_configuration], [])

        content {
          dynamic "authorization_config" {
            for_each = try([fsx_windows_file_server_volume_configuration.value.authorization_config], [])

            content {
              credentials_parameter = authorization_config.value.credentials_parameter
              domain                = authorization_config.value.domain
            }
          }

          file_system_id = fsx_windows_file_server_volume_configuration.value.file_system_id
          root_directory = fsx_windows_file_server_volume_configuration.value.root_directory
        }
      }

      host_path = try(volume.value.host_path, null)
      name      = try(volume.value.name, volume.key)
    }
  }

  tags = merge(var.tags, var.task_tags)

  depends_on = [
    aws_iam_role_policy_attachment.tasks,
    aws_iam_role_policy_attachment.task_exec,
    aws_iam_role_policy_attachment.task_exec_additional,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Task Execution - IAM Role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
################################################################################

locals {
  task_exec_iam_role_name = try(coalesce(var.task_exec_iam_role_name, var.name), "")

  create_task_exec_iam_role = local.create_task_definition && var.create_task_exec_iam_role
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
  description = coalesce(var.task_exec_iam_role_description, "Task execution role for ${local.task_exec_iam_role_name}")

  assume_role_policy    = data.aws_iam_policy_document.task_exec_assume[0].json
  max_session_duration  = var.task_exec_iam_role_max_session_duration
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
    for_each = var.task_exec_iam_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

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
  path        = var.task_exec_iam_policy_path
  tags        = merge(var.tags, var.task_exec_iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "task_exec" {
  count = local.create_task_exec_policy ? 1 : 0

  role       = aws_iam_role.task_exec[0].name
  policy_arn = aws_iam_policy.task_exec[0].arn
}

################################################################################
# Tasks - IAM role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html
################################################################################

locals {
  tasks_iam_role_name   = try(coalesce(var.tasks_iam_role_name, var.name), "")
  create_tasks_iam_role = local.create_task_definition && var.create_tasks_iam_role
}

data "aws_iam_policy_document" "tasks_assume" {
  count = local.create_tasks_iam_role ? 1 : 0

  statement {
    sid     = "ECSTasksAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html#create_task_iam_policy_and_role
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:${local.partition}:ecs:${local.region}:${local.account_id}:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }
}

resource "aws_iam_role" "tasks" {
  count = local.create_tasks_iam_role ? 1 : 0

  name        = var.tasks_iam_role_use_name_prefix ? null : local.tasks_iam_role_name
  name_prefix = var.tasks_iam_role_use_name_prefix ? "${local.tasks_iam_role_name}-" : null
  path        = var.tasks_iam_role_path
  description = var.tasks_iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.tasks_assume[0].json
  permissions_boundary  = var.tasks_iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.tasks_iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "tasks" {
  for_each = { for k, v in var.tasks_iam_role_policies : k => v if local.create_tasks_iam_role }

  role       = aws_iam_role.tasks[0].name
  policy_arn = each.value
}

data "aws_iam_policy_document" "tasks" {
  count = local.create_tasks_iam_role && (length(var.tasks_iam_role_statements) > 0 || var.enable_execute_command) ? 1 : 0

  dynamic "statement" {
    for_each = var.enable_execute_command ? [1] : []

    content {
      sid = "ECSExec"
      actions = [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel",
      ]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = var.tasks_iam_role_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_role_policy" "tasks" {
  count = local.create_tasks_iam_role && (length(var.tasks_iam_role_statements) > 0 || var.enable_execute_command) ? 1 : 0

  name        = var.tasks_iam_role_use_name_prefix ? null : local.tasks_iam_role_name
  name_prefix = var.tasks_iam_role_use_name_prefix ? "${local.tasks_iam_role_name}-" : null
  policy      = data.aws_iam_policy_document.tasks[0].json
  role        = aws_iam_role.tasks[0].id
}

################################################################################
# Task Set
################################################################################

resource "aws_ecs_task_set" "this" {
  # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ecs-taskset.html
  count = local.create_task_definition && local.is_external_deployment && !var.ignore_task_definition_changes ? 1 : 0

  service         = try(aws_ecs_service.this[0].id, aws_ecs_service.ignore_task_definition[0].id)
  cluster         = var.cluster_arn
  external_id     = var.external_id
  task_definition = local.task_definition

  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? [local.network_configuration] : []

    content {
      assign_public_ip = network_configuration.value.assign_public_ip
      security_groups  = network_configuration.value.security_groups
      subnets          = network_configuration.value.subnets
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer

    content {
      load_balancer_name = try(load_balancer.value.load_balancer_name, null)
      target_group_arn   = try(load_balancer.value.target_group_arn, null)
      container_name     = load_balancer.value.container_name
      container_port     = try(load_balancer.value.container_port, null)
    }
  }

  dynamic "service_registries" {
    for_each = length(var.service_registries) > 0 ? [var.service_registries] : []

    content {
      container_name = try(service_registries.value.container_name, null)
      container_port = try(service_registries.value.container_port, null)
      port           = try(service_registries.value.port, null)
      registry_arn   = service_registries.value.registry_arn
    }
  }

  launch_type = length(var.capacity_provider_strategy) > 0 ? null : var.launch_type

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy

    content {
      base              = try(capacity_provider_strategy.value.base, null)
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = try(capacity_provider_strategy.value.weight, null)
    }
  }

  platform_version = local.is_fargate ? var.platform_version : null

  dynamic "scale" {
    for_each = length(var.scale) > 0 ? [var.scale] : []

    content {
      unit  = try(scale.value.unit, null)
      value = try(scale.value.value, null)
    }
  }

  force_delete              = var.force_delete
  wait_until_stable         = var.wait_until_stable
  wait_until_stable_timeout = var.wait_until_stable_timeout

  tags = merge(var.tags, var.task_tags)

  lifecycle {
    ignore_changes = [
      scale, # Always ignored
    ]
  }
}

################################################################################
# Task Set - Ignore `task_definition`
################################################################################

resource "aws_ecs_task_set" "ignore_task_definition" {
  # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ecs-taskset.html
  count = local.create_task_definition && local.is_external_deployment && var.ignore_task_definition_changes ? 1 : 0

  service         = try(aws_ecs_service.this[0].id, aws_ecs_service.ignore_task_definition[0].id)
  cluster         = var.cluster_arn
  external_id     = var.external_id
  task_definition = local.task_definition

  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? [local.network_configuration] : []

    content {
      assign_public_ip = network_configuration.value.assign_public_ip
      security_groups  = network_configuration.value.security_groups
      subnets          = network_configuration.value.subnets
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer

    content {
      load_balancer_name = try(load_balancer.value.load_balancer_name, null)
      target_group_arn   = try(load_balancer.value.target_group_arn, null)
      container_name     = load_balancer.value.container_name
      container_port     = try(load_balancer.value.container_port, null)
    }
  }

  dynamic "service_registries" {
    for_each = length(var.service_registries) > 0 ? [var.service_registries] : []

    content {
      container_name = try(service_registries.value.container_name, null)
      container_port = try(service_registries.value.container_port, null)
      port           = try(service_registries.value.port, null)
      registry_arn   = service_registries.value.registry_arn
    }
  }

  launch_type = length(var.capacity_provider_strategy) > 0 ? null : var.launch_type

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy

    content {
      base              = try(capacity_provider_strategy.value.base, null)
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = try(capacity_provider_strategy.value.weight, null)
    }
  }

  platform_version = local.is_fargate ? var.platform_version : null

  dynamic "scale" {
    for_each = length(var.scale) > 0 ? [var.scale] : []

    content {
      unit  = try(scale.value.unit, null)
      value = try(scale.value.value, null)
    }
  }

  force_delete              = var.force_delete
  wait_until_stable         = var.wait_until_stable
  wait_until_stable_timeout = var.wait_until_stable_timeout

  tags = merge(var.tags, var.task_tags)

  lifecycle {
    ignore_changes = [
      scale, # Always ignored
      task_definition,
    ]
  }
}

################################################################################
# Autoscaling
################################################################################

locals {
  enable_autoscaling = local.create_service && var.enable_autoscaling && !local.is_daemon

  cluster_name = try(element(split("/", var.cluster_arn), 1), "")
}

resource "aws_appautoscaling_target" "this" {
  count = local.enable_autoscaling ? 1 : 0

  # Desired needs to be between or equal to min/max
  min_capacity = min(var.autoscaling_min_capacity, var.desired_count)
  max_capacity = max(var.autoscaling_max_capacity, var.desired_count)

  resource_id        = "service/${local.cluster_name}/${try(aws_ecs_service.this[0].name, aws_ecs_service.ignore_task_definition[0].name)}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  tags               = var.tags
}

resource "aws_appautoscaling_policy" "this" {
  for_each = { for k, v in var.autoscaling_policies : k => v if local.enable_autoscaling }

  name               = try(each.value.name, each.key)
  policy_type        = try(each.value.policy_type, "TargetTrackingScaling")
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  dynamic "step_scaling_policy_configuration" {
    for_each = try([each.value.step_scaling_policy_configuration], [])

    content {
      adjustment_type          = try(step_scaling_policy_configuration.value.adjustment_type, null)
      cooldown                 = try(step_scaling_policy_configuration.value.cooldown, null)
      metric_aggregation_type  = try(step_scaling_policy_configuration.value.metric_aggregation_type, null)
      min_adjustment_magnitude = try(step_scaling_policy_configuration.value.min_adjustment_magnitude, null)

      dynamic "step_adjustment" {
        for_each = try(step_scaling_policy_configuration.value.step_adjustment, [])

        content {
          metric_interval_lower_bound = try(step_adjustment.value.metric_interval_lower_bound, null)
          metric_interval_upper_bound = try(step_adjustment.value.metric_interval_upper_bound, null)
          scaling_adjustment          = try(step_adjustment.value.scaling_adjustment, null)
        }
      }
    }
  }

  dynamic "target_tracking_scaling_policy_configuration" {
    for_each = try(each.value.policy_type, null) == "TargetTrackingScaling" ? try([each.value.target_tracking_scaling_policy_configuration], []) : []

    content {
      dynamic "customized_metric_specification" {
        for_each = try([target_tracking_scaling_policy_configuration.value.customized_metric_specification], [])

        content {
          dynamic "dimensions" {
            for_each = try(customized_metric_specification.value.dimensions, [])

            content {
              name  = dimensions.value.name
              value = dimensions.value.value
            }
          }

          metric_name = customized_metric_specification.value.metric_name
          namespace   = customized_metric_specification.value.namespace
          statistic   = customized_metric_specification.value.statistic
          unit        = try(customized_metric_specification.value.unit, null)
        }
      }

      disable_scale_in = try(target_tracking_scaling_policy_configuration.value.disable_scale_in, null)

      dynamic "predefined_metric_specification" {
        for_each = try([target_tracking_scaling_policy_configuration.value.predefined_metric_specification], [])

        content {
          predefined_metric_type = predefined_metric_specification.value.predefined_metric_type
          resource_label         = try(predefined_metric_specification.value.resource_label, null)
        }
      }

      scale_in_cooldown  = try(target_tracking_scaling_policy_configuration.value.scale_in_cooldown, 300)
      scale_out_cooldown = try(target_tracking_scaling_policy_configuration.value.scale_out_cooldown, 60)
      target_value       = try(target_tracking_scaling_policy_configuration.value.target_value, 75)
    }
  }
}

resource "aws_appautoscaling_scheduled_action" "this" {
  for_each = { for k, v in var.autoscaling_scheduled_actions : k => v if local.enable_autoscaling }

  name               = try(each.value.name, each.key)
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension

  scalable_target_action {
    min_capacity = each.value.min_capacity
    max_capacity = each.value.max_capacity
  }

  schedule   = each.value.schedule
  start_time = try(each.value.start_time, null)
  end_time   = try(each.value.end_time, null)
  timezone   = try(each.value.timezone, null)
}

################################################################################
# Security Group
################################################################################

locals {
  create_security_group = var.create && var.create_security_group && var.network_mode == "awsvpc"
  security_group_name   = try(coalesce(var.security_group_name, var.name), "")
}

data "aws_subnet" "this" {
  count = local.create_security_group ? 1 : 0

  id = element(var.subnet_ids, 0)
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  name        = var.security_group_use_name_prefix ? null : local.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.security_group_name}-" : null
  description = var.security_group_description
  vpc_id      = data.aws_subnet.this[0].vpc_id

  tags = merge(
    var.tags,
    { "Name" = local.security_group_name },
    var.security_group_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "this" {
  for_each = { for k, v in var.security_group_rules : k => v if local.create_security_group }

  # Required
  security_group_id = aws_security_group.this[0].id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = each.value.type

  # Optional
  description              = lookup(each.value, "description", null)
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  self                     = lookup(each.value, "self", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}
