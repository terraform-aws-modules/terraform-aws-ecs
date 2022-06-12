################################################################################
# Service
################################################################################

resource "aws_ecs_service" "this" {
  count = var.create && !var.ignore_desired_count_changes ? 1 : 0

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy

    content {
      base              = try(capacity_provider_strategy.value.base, null)
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = try(capacity_provider.value.weight, null)
    }
  }

  cluster = var.cluster

  dynamic "deployment_circuit_breaker" {
    for_each = [var.deployment_circuit_breaker]

    content {
      enable   = deployment_circuit_breaker.value.enable
      rollback = deployment_circuit_breaker.value.rollback
    }
  }

  dynamic "deployment_controller" {
    for_each = [var.deployment_controller]

    content {
      type = try(deployment_controller.value.type, null)
    }
  }

  deployment_maximum_percent         = var.scheduling_strategy == "DAEMON" ? null : var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.scheduling_strategy == "DAEMON" ? null : var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  enable_execute_command             = var.enable_execute_command
  force_new_deployment               = var.force_new_deployment
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  iam_role                           = var.iam_role
  launch_type                        = var.launch_type

  dynamic "load_balancer" {
    for_each = var.load_balancer

    content {
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
      elb_name         = try(load_balancer.value.elb_name, null)
      target_group_arn = try(load_balancer.value.target_group_arn, null)
    }
  }

  name = var.name

  dynamic "network_configuration" {
    for_each = [var.network_configuration]

    content {
      assign_public_ip = try(network_configuration.value.assign_public_ip, null)
      security_groups  = try(network_configuration.value.security_groups, null)
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

  platform_version    = var.launch_type == "FARGATE" ? var.platform_version : null
  propagate_tags      = var.propagate_tags
  scheduling_strategy = var.launch_type == "FARGATE" ? "REPLICA" : var.scheduling_strategy

  dynamic "service_registries" {
    for_each = [var.service_registries]

    content {
      container_name = try(service_registries.value.container_name, null)
      container_port = try(service_registries.value.container_port, null)
      port           = try(service_registries.value.port, null)
      registry_arn   = service_registries.value.registry_arn
    }
  }

  task_definition       = var.task_definition
  wait_for_steady_state = var.wait_for_steady_state

  tags = var.tags
}

################################################################################
# Service - Ignore `desired_count`
################################################################################

resource "aws_ecs_service" "idc" {
  count = var.create && var.ignore_desired_count_changes ? 1 : 0

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy

    content {
      base              = try(capacity_provider_strategy.value.base, null)
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = try(capacity_provider.value.weight, null)
    }
  }

  cluster = var.cluster

  dynamic "deployment_circuit_breaker" {
    for_each = [var.deployment_circuit_breaker]

    content {
      enable   = deployment_circuit_breaker.value.enable
      rollback = deployment_circuit_breaker.value.rollback
    }
  }

  dynamic "deployment_controller" {
    for_each = [var.deployment_controller]

    content {
      type = try(deployment_controller.value.type, null)
    }
  }

  deployment_maximum_percent         = var.scheduling_strategy == "DAEMON" ? null : var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.scheduling_strategy == "DAEMON" ? null : var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  enable_execute_command             = var.enable_execute_command
  force_new_deployment               = var.force_new_deployment
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  iam_role                           = var.iam_role
  launch_type                        = var.launch_type

  dynamic "load_balancer" {
    for_each = var.load_balancer

    content {
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
      elb_name         = try(load_balancer.value.elb_name, null)
      target_group_arn = try(load_balancer.value.target_group_arn, null)
    }
  }

  name = var.name

  dynamic "network_configuration" {
    for_each = [var.network_configuration]

    content {
      assign_public_ip = try(network_configuration.value.assign_public_ip, null)
      security_groups  = try(network_configuration.value.security_groups, null)
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

  platform_version    = var.launch_type == "FARGATE" ? var.platform_version : null
  propagate_tags      = var.propagate_tags
  scheduling_strategy = var.launch_type == "FARGATE" ? "REPLICA" : var.scheduling_strategy

  dynamic "service_registries" {
    for_each = [var.service_registries]

    content {
      container_name = try(service_registries.value.container_name, null)
      container_port = try(service_registries.value.container_port, null)
      port           = try(service_registries.value.port, null)
      registry_arn   = service_registries.value.registry_arn
    }
  }

  task_definition       = var.task_definition
  wait_for_steady_state = var.wait_for_steady_state

  tags = var.tags

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}

################################################################################
# Task Definition
################################################################################

resource "aws_ecs_task_definition" "this" {
  count = var.create && var.create_task_definition ? 1 : 0

  container_definitions = var.task_container_definitions
  cpu                   = var.task_cpu

  dynamic "ephemeral_storage" {
    for_each = [var.task_ephemeral_storage]

    content {
      size_in_gib = ephemeral_storage.value.size_in_gib
    }
  }

  execution_role_arn = var.task_execution_role_arn
  family             = var.task_family

  dynamic "inference_accelerator" {
    for_each = var.task_inference_accelerator

    content {
      device_name = inference_accelerator.value.device_name
      device_type = inference_accelerator.value.device_type
    }
  }

  ipc_mode     = var.task_ipc_mode
  memory       = var.task_memory
  network_mode = var.task_network_mode
  pid_mode     = var.task_pid_mode

  dynamic "placement_constraints" {
    for_each = var.task_placement_constraints

    content {
      expression = try(placement_constraints.value.expression, null)
      type       = placement_constraints.value.type
    }
  }

  dynamic "proxy_configuration" {
    for_each = [var.task_proxy_configuration]

    content {
      container_name = proxy_configuration.value.container_name
      properties     = try(proxy_configuration.value.properties, null)
      type           = try(proxy_configuration.value.type, null)
    }
  }

  requires_compatibilities = var.task_requires_compatibilities

  dynamic "runtime_platform" {
    for_each = [var.task_runtime_platform]

    content {
      cpu_architecture        = try(runtime_platform.value.cpu_architecture, null)
      operating_system_family = try(runtime_platform.value.operating_system_family, null)
    }
  }

  skip_destroy  = var.task_skip_destroy
  task_role_arn = var.task_role_arn

  dynamic "volume" {
    for_each = var.task_volume

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
      name      = volume.value.name
    }
  }

  tags = var.tags
}
