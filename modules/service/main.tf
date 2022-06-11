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

# Ignores changes to `desired_count`
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
