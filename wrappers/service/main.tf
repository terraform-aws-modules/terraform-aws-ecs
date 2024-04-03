module "wrapper" {
  source = "../../modules/service"

  for_each = var.items

  alarms                   = try(each.value.alarms, var.defaults.alarms, {})
  assign_public_ip         = try(each.value.assign_public_ip, var.defaults.assign_public_ip, false)
  autoscaling_max_capacity = try(each.value.autoscaling_max_capacity, var.defaults.autoscaling_max_capacity, 10)
  autoscaling_min_capacity = try(each.value.autoscaling_min_capacity, var.defaults.autoscaling_min_capacity, 1)
  autoscaling_policies = try(each.value.autoscaling_policies, var.defaults.autoscaling_policies, {
    cpu = {
      policy_type = "TargetTrackingScaling"

      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
      }
    }
    memory = {
      policy_type = "TargetTrackingScaling"

      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
      }
    }
  })
  autoscaling_scheduled_actions      = try(each.value.autoscaling_scheduled_actions, var.defaults.autoscaling_scheduled_actions, {})
  capacity_provider_strategy         = try(each.value.capacity_provider_strategy, var.defaults.capacity_provider_strategy, {})
  cluster_arn                        = try(each.value.cluster_arn, var.defaults.cluster_arn, "")
  container_definition_defaults      = try(each.value.container_definition_defaults, var.defaults.container_definition_defaults, {})
  container_definitions              = try(each.value.container_definitions, var.defaults.container_definitions, {})
  cpu                                = try(each.value.cpu, var.defaults.cpu, 1024)
  create                             = try(each.value.create, var.defaults.create, true)
  create_iam_role                    = try(each.value.create_iam_role, var.defaults.create_iam_role, true)
  create_security_group              = try(each.value.create_security_group, var.defaults.create_security_group, true)
  create_service                     = try(each.value.create_service, var.defaults.create_service, true)
  create_task_definition             = try(each.value.create_task_definition, var.defaults.create_task_definition, true)
  create_task_exec_iam_role          = try(each.value.create_task_exec_iam_role, var.defaults.create_task_exec_iam_role, true)
  create_task_exec_policy            = try(each.value.create_task_exec_policy, var.defaults.create_task_exec_policy, true)
  create_tasks_iam_role              = try(each.value.create_tasks_iam_role, var.defaults.create_tasks_iam_role, true)
  deployment_circuit_breaker         = try(each.value.deployment_circuit_breaker, var.defaults.deployment_circuit_breaker, {})
  deployment_controller              = try(each.value.deployment_controller, var.defaults.deployment_controller, {})
  deployment_maximum_percent         = try(each.value.deployment_maximum_percent, var.defaults.deployment_maximum_percent, 200)
  deployment_minimum_healthy_percent = try(each.value.deployment_minimum_healthy_percent, var.defaults.deployment_minimum_healthy_percent, 66)
  desired_count                      = try(each.value.desired_count, var.defaults.desired_count, 1)
  enable_autoscaling                 = try(each.value.enable_autoscaling, var.defaults.enable_autoscaling, true)
  enable_ecs_managed_tags            = try(each.value.enable_ecs_managed_tags, var.defaults.enable_ecs_managed_tags, true)
  enable_execute_command             = try(each.value.enable_execute_command, var.defaults.enable_execute_command, false)
  ephemeral_storage                  = try(each.value.ephemeral_storage, var.defaults.ephemeral_storage, {})
  external_id                        = try(each.value.external_id, var.defaults.external_id, null)
  family                             = try(each.value.family, var.defaults.family, null)
  force_delete                       = try(each.value.force_delete, var.defaults.force_delete, null)
  force_new_deployment               = try(each.value.force_new_deployment, var.defaults.force_new_deployment, true)
  health_check_grace_period_seconds  = try(each.value.health_check_grace_period_seconds, var.defaults.health_check_grace_period_seconds, null)
  iam_role_arn                       = try(each.value.iam_role_arn, var.defaults.iam_role_arn, null)
  iam_role_description               = try(each.value.iam_role_description, var.defaults.iam_role_description, null)
  iam_role_name                      = try(each.value.iam_role_name, var.defaults.iam_role_name, null)
  iam_role_path                      = try(each.value.iam_role_path, var.defaults.iam_role_path, null)
  iam_role_permissions_boundary      = try(each.value.iam_role_permissions_boundary, var.defaults.iam_role_permissions_boundary, null)
  iam_role_statements                = try(each.value.iam_role_statements, var.defaults.iam_role_statements, {})
  iam_role_tags                      = try(each.value.iam_role_tags, var.defaults.iam_role_tags, {})
  iam_role_use_name_prefix           = try(each.value.iam_role_use_name_prefix, var.defaults.iam_role_use_name_prefix, true)
  ignore_task_definition_changes     = try(each.value.ignore_task_definition_changes, var.defaults.ignore_task_definition_changes, false)
  inference_accelerator              = try(each.value.inference_accelerator, var.defaults.inference_accelerator, {})
  ipc_mode                           = try(each.value.ipc_mode, var.defaults.ipc_mode, null)
  launch_type                        = try(each.value.launch_type, var.defaults.launch_type, "FARGATE")
  load_balancer                      = try(each.value.load_balancer, var.defaults.load_balancer, {})
  memory                             = try(each.value.memory, var.defaults.memory, 2048)
  name                               = try(each.value.name, var.defaults.name, null)
  network_mode                       = try(each.value.network_mode, var.defaults.network_mode, "awsvpc")
  ordered_placement_strategy         = try(each.value.ordered_placement_strategy, var.defaults.ordered_placement_strategy, {})
  pid_mode                           = try(each.value.pid_mode, var.defaults.pid_mode, null)
  placement_constraints              = try(each.value.placement_constraints, var.defaults.placement_constraints, {})
  platform_version                   = try(each.value.platform_version, var.defaults.platform_version, null)
  propagate_tags                     = try(each.value.propagate_tags, var.defaults.propagate_tags, null)
  proxy_configuration                = try(each.value.proxy_configuration, var.defaults.proxy_configuration, {})
  requires_compatibilities           = try(each.value.requires_compatibilities, var.defaults.requires_compatibilities, ["FARGATE"])
  runtime_platform = try(each.value.runtime_platform, var.defaults.runtime_platform, {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  })
  scale                                   = try(each.value.scale, var.defaults.scale, {})
  scheduling_strategy                     = try(each.value.scheduling_strategy, var.defaults.scheduling_strategy, null)
  security_group_description              = try(each.value.security_group_description, var.defaults.security_group_description, null)
  security_group_ids                      = try(each.value.security_group_ids, var.defaults.security_group_ids, [])
  security_group_name                     = try(each.value.security_group_name, var.defaults.security_group_name, null)
  security_group_rules                    = try(each.value.security_group_rules, var.defaults.security_group_rules, {})
  security_group_tags                     = try(each.value.security_group_tags, var.defaults.security_group_tags, {})
  security_group_use_name_prefix          = try(each.value.security_group_use_name_prefix, var.defaults.security_group_use_name_prefix, true)
  service_connect_configuration           = try(each.value.service_connect_configuration, var.defaults.service_connect_configuration, {})
  service_registries                      = try(each.value.service_registries, var.defaults.service_registries, {})
  service_tags                            = try(each.value.service_tags, var.defaults.service_tags, {})
  skip_destroy                            = try(each.value.skip_destroy, var.defaults.skip_destroy, null)
  subnet_ids                              = try(each.value.subnet_ids, var.defaults.subnet_ids, [])
  tags                                    = try(each.value.tags, var.defaults.tags, {})
  task_definition_arn                     = try(each.value.task_definition_arn, var.defaults.task_definition_arn, null)
  task_definition_placement_constraints   = try(each.value.task_definition_placement_constraints, var.defaults.task_definition_placement_constraints, {})
  task_exec_iam_role_arn                  = try(each.value.task_exec_iam_role_arn, var.defaults.task_exec_iam_role_arn, null)
  task_exec_iam_role_description          = try(each.value.task_exec_iam_role_description, var.defaults.task_exec_iam_role_description, null)
  task_exec_iam_role_max_session_duration = try(each.value.task_exec_iam_role_max_session_duration, var.defaults.task_exec_iam_role_max_session_duration, null)
  task_exec_iam_role_name                 = try(each.value.task_exec_iam_role_name, var.defaults.task_exec_iam_role_name, null)
  task_exec_iam_role_path                 = try(each.value.task_exec_iam_role_path, var.defaults.task_exec_iam_role_path, null)
  task_exec_iam_role_permissions_boundary = try(each.value.task_exec_iam_role_permissions_boundary, var.defaults.task_exec_iam_role_permissions_boundary, null)
  task_exec_iam_role_policies             = try(each.value.task_exec_iam_role_policies, var.defaults.task_exec_iam_role_policies, {})
  task_exec_iam_role_tags                 = try(each.value.task_exec_iam_role_tags, var.defaults.task_exec_iam_role_tags, {})
  task_exec_iam_role_use_name_prefix      = try(each.value.task_exec_iam_role_use_name_prefix, var.defaults.task_exec_iam_role_use_name_prefix, true)
  task_exec_iam_statements                = try(each.value.task_exec_iam_statements, var.defaults.task_exec_iam_statements, {})
  task_exec_secret_arns                   = try(each.value.task_exec_secret_arns, var.defaults.task_exec_secret_arns, ["arn:aws:secretsmanager:*:*:secret:*"])
  task_exec_ssm_param_arns                = try(each.value.task_exec_ssm_param_arns, var.defaults.task_exec_ssm_param_arns, ["arn:aws:ssm:*:*:parameter/*"])
  task_tags                               = try(each.value.task_tags, var.defaults.task_tags, {})
  tasks_iam_role_arn                      = try(each.value.tasks_iam_role_arn, var.defaults.tasks_iam_role_arn, null)
  tasks_iam_role_description              = try(each.value.tasks_iam_role_description, var.defaults.tasks_iam_role_description, null)
  tasks_iam_role_name                     = try(each.value.tasks_iam_role_name, var.defaults.tasks_iam_role_name, null)
  tasks_iam_role_path                     = try(each.value.tasks_iam_role_path, var.defaults.tasks_iam_role_path, null)
  tasks_iam_role_permissions_boundary     = try(each.value.tasks_iam_role_permissions_boundary, var.defaults.tasks_iam_role_permissions_boundary, null)
  tasks_iam_role_policies                 = try(each.value.tasks_iam_role_policies, var.defaults.tasks_iam_role_policies, {})
  tasks_iam_role_statements               = try(each.value.tasks_iam_role_statements, var.defaults.tasks_iam_role_statements, {})
  tasks_iam_role_tags                     = try(each.value.tasks_iam_role_tags, var.defaults.tasks_iam_role_tags, {})
  tasks_iam_role_use_name_prefix          = try(each.value.tasks_iam_role_use_name_prefix, var.defaults.tasks_iam_role_use_name_prefix, true)
  timeouts                                = try(each.value.timeouts, var.defaults.timeouts, {})
  triggers                                = try(each.value.triggers, var.defaults.triggers, {})
  volume                                  = try(each.value.volume, var.defaults.volume, {})
  wait_for_steady_state                   = try(each.value.wait_for_steady_state, var.defaults.wait_for_steady_state, null)
  wait_until_stable                       = try(each.value.wait_until_stable, var.defaults.wait_until_stable, null)
  wait_until_stable_timeout               = try(each.value.wait_until_stable_timeout, var.defaults.wait_until_stable_timeout, null)
}
