################################################################################
# Cluster
################################################################################

module "cluster" {
  source = "./modules/cluster"

  create = var.create

  # Cluster
  cluster_name                     = var.cluster_name
  cluster_configuration            = var.cluster_configuration
  cluster_settings                 = var.cluster_settings
  cluster_service_connect_defaults = var.cluster_service_connect_defaults

  # Cluster Cloudwatch log group
  create_cloudwatch_log_group            = var.create_cloudwatch_log_group
  cloudwatch_log_group_name              = var.cloudwatch_log_group_name
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = var.cloudwatch_log_group_kms_key_id
  cloudwatch_log_group_tags              = var.cloudwatch_log_group_tags

  # Cluster capacity providers
  default_capacity_provider_use_fargate = var.default_capacity_provider_use_fargate
  fargate_capacity_providers            = var.fargate_capacity_providers
  autoscaling_capacity_providers        = var.autoscaling_capacity_providers

  # Task execution IAM role
  create_task_exec_iam_role               = var.create_task_exec_iam_role
  task_exec_iam_role_name                 = var.task_exec_iam_role_name
  task_exec_iam_role_use_name_prefix      = var.task_exec_iam_role_use_name_prefix
  task_exec_iam_role_path                 = var.task_exec_iam_role_path
  task_exec_iam_role_description          = var.task_exec_iam_role_description
  task_exec_iam_role_permissions_boundary = var.task_exec_iam_role_permissions_boundary
  task_exec_iam_role_tags                 = var.task_exec_iam_role_tags
  task_exec_iam_role_policies             = var.task_exec_iam_role_policies

  # Task execution IAM role policy
  create_task_exec_policy  = var.create_task_exec_policy
  task_exec_ssm_param_arns = var.task_exec_ssm_param_arns
  task_exec_secret_arns    = var.task_exec_secret_arns
  task_exec_iam_statements = var.task_exec_iam_statements

  tags = merge(var.tags, var.cluster_tags)
}

################################################################################
# Service(s)
################################################################################

module "service" {
  source = "./modules/service"

  for_each = { for k, v in var.services : k => v if var.create }

  create         = try(each.value.create, true)
  create_service = try(each.value.create_service, true)

  # Service
  ignore_task_definition_changes     = try(each.value.ignore_task_definition_changes, false)
  alarms                             = try(each.value.alarms, {})
  capacity_provider_strategy         = try(each.value.capacity_provider_strategy, {})
  cluster_arn                        = module.cluster.arn
  deployment_circuit_breaker         = try(each.value.deployment_circuit_breaker, {})
  deployment_controller              = try(each.value.deployment_controller, {})
  deployment_maximum_percent         = try(each.value.deployment_maximum_percent, 200)
  deployment_minimum_healthy_percent = try(each.value.deployment_minimum_healthy_percent, 66)
  desired_count                      = try(each.value.desired_count, 1)
  enable_ecs_managed_tags            = try(each.value.enable_ecs_managed_tags, true)
  enable_execute_command             = try(each.value.enable_execute_command, false)
  force_new_deployment               = try(each.value.force_new_deployment, true)
  health_check_grace_period_seconds  = try(each.value.health_check_grace_period_seconds, null)
  launch_type                        = try(each.value.launch_type, "FARGATE")
  load_balancer                      = lookup(each.value, "load_balancer", {})
  name                               = try(each.value.name, each.key)
  assign_public_ip                   = try(each.value.assign_public_ip, false)
  security_group_ids                 = lookup(each.value, "security_group_ids", [])
  subnet_ids                         = lookup(each.value, "subnet_ids", [])
  ordered_placement_strategy         = try(each.value.ordered_placement_strategy, {})
  placement_constraints              = try(each.value.placement_constraints, {})
  platform_version                   = try(each.value.platform_version, null)
  propagate_tags                     = try(each.value.propagate_tags, null)
  scheduling_strategy                = try(each.value.scheduling_strategy, null)
  service_connect_configuration      = lookup(each.value, "service_connect_configuration", {})
  service_registries                 = lookup(each.value, "service_registries", {})
  timeouts                           = try(each.value.timeouts, {})
  triggers                           = try(each.value.triggers, {})
  wait_for_steady_state              = try(each.value.wait_for_steady_state, null)

  # Service IAM role
  create_iam_role               = try(each.value.create_iam_role, true)
  iam_role_arn                  = lookup(each.value, "iam_role_arn", null)
  iam_role_name                 = try(each.value.iam_role_name, null)
  iam_role_use_name_prefix      = try(each.value.iam_role_use_name_prefix, true)
  iam_role_path                 = try(each.value.iam_role_path, null)
  iam_role_description          = try(each.value.iam_role_description, null)
  iam_role_permissions_boundary = try(each.value.iam_role_permissions_boundary, null)
  iam_role_tags                 = try(each.value.iam_role_tags, {})
  iam_role_statements           = lookup(each.value, "iam_role_statements", {})

  # Task definition
  create_task_definition        = try(each.value.create_task_definition, true)
  task_definition_arn           = lookup(each.value, "task_definition_arn", null)
  container_definitions         = try(each.value.container_definitions, {})
  container_definition_defaults = try(each.value.container_definition_defaults, {})
  cpu                           = try(each.value.cpu, 1024)
  ephemeral_storage             = try(each.value.ephemeral_storage, {})
  family                        = try(each.value.family, null)
  inference_accelerator         = try(each.value.inference_accelerator, {})
  ipc_mode                      = try(each.value.ipc_mode, null)
  memory                        = try(each.value.memory, 2048)
  network_mode                  = try(each.value.network_mode, "awsvpc")
  pid_mode                      = try(each.value.pid_mode, null)
  proxy_configuration           = try(each.value.proxy_configuration, {})
  requires_compatibilities      = try(each.value.requires_compatibilities, ["FARGATE"])
  runtime_platform = try(each.value.runtime_platform, {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  })
  skip_destroy = try(each.value.skip_destroy, null)
  volume       = try(each.value.volume, {})
  task_tags    = try(each.value.task_tags, {})

  # Task execution IAM role
  create_task_exec_iam_role               = try(each.value.create_task_exec_iam_role, true)
  task_exec_iam_role_arn                  = lookup(each.value, "task_exec_iam_role_arn", null)
  task_exec_iam_role_name                 = try(each.value.task_exec_iam_role_name, null)
  task_exec_iam_role_use_name_prefix      = try(each.value.task_exec_iam_role_use_name_prefix, true)
  task_exec_iam_role_path                 = try(each.value.task_exec_iam_role_path, null)
  task_exec_iam_role_description          = try(each.value.task_exec_iam_role_description, null)
  task_exec_iam_role_permissions_boundary = try(each.value.task_exec_iam_role_permissions_boundary, null)
  task_exec_iam_role_tags                 = try(each.value.task_exec_iam_role_tags, {})
  task_exec_iam_role_policies             = try(each.value.task_exec_iam_role_policies, {})
  task_exec_iam_role_max_session_duration = try(each.value.task_exec_iam_role_max_session_duration, null)

  # Task execution IAM role policy
  create_task_exec_policy  = try(each.value.create_task_exec_policy, true)
  task_exec_ssm_param_arns = lookup(each.value, "task_exec_ssm_param_arns", ["arn:aws:ssm:*:*:parameter/*"])
  task_exec_secret_arns    = lookup(each.value, "task_exec_secret_arns", ["arn:aws:secretsmanager:*:*:secret:*"])
  task_exec_iam_statements = lookup(each.value, "task_exec_iam_statements", {})

  # Tasks - IAM role
  create_tasks_iam_role               = try(each.value.create_tasks_iam_role, true)
  tasks_iam_role_arn                  = lookup(each.value, "tasks_iam_role_arn", null)
  tasks_iam_role_name                 = try(each.value.tasks_iam_role_name, null)
  tasks_iam_role_use_name_prefix      = try(each.value.tasks_iam_role_use_name_prefix, true)
  tasks_iam_role_path                 = try(each.value.tasks_iam_role_path, null)
  tasks_iam_role_description          = try(each.value.tasks_iam_role_description, null)
  tasks_iam_role_permissions_boundary = try(each.value.tasks_iam_role_permissions_boundary, null)
  tasks_iam_role_tags                 = try(each.value.tasks_iam_role_tags, {})
  tasks_iam_role_policies             = lookup(each.value, "tasks_iam_role_policies", {})
  tasks_iam_role_statements           = lookup(each.value, "tasks_iam_role_statements", {})

  # Task set
  external_id               = try(each.value.external_id, null)
  scale                     = try(each.value.scale, {})
  force_delete              = try(each.value.force_delete, null)
  wait_until_stable         = try(each.value.wait_until_stable, null)
  wait_until_stable_timeout = try(each.value.wait_until_stable_timeout, null)

  # Autoscaling
  enable_autoscaling       = try(each.value.enable_autoscaling, true)
  autoscaling_min_capacity = try(each.value.autoscaling_min_capacity, 1)
  autoscaling_max_capacity = try(each.value.autoscaling_max_capacity, 10)
  autoscaling_policies = try(each.value.autoscaling_policies, {
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
  autoscaling_scheduled_actions = try(each.value.autoscaling_scheduled_actions, {})

  # Security Group
  create_security_group          = try(each.value.create_security_group, true)
  security_group_name            = try(each.value.security_group_name, null)
  security_group_use_name_prefix = try(each.value.security_group_use_name_prefix, true)
  security_group_description     = try(each.value.security_group_description, null)
  security_group_rules           = lookup(each.value, "security_group_rules", {})
  security_group_tags            = try(each.value.security_group_tags, {})

  tags = merge(var.tags, try(each.value.tags, {}))
}
