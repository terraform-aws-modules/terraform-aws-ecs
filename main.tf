################################################################################
# Cluster
################################################################################

module "cluster" {
  source = "./modules/cluster"

  create = var.create
  region = var.region

  # Cluster
  configuration            = var.cluster_configuration
  name                     = var.cluster_name
  service_connect_defaults = var.cluster_service_connect_defaults
  setting                  = var.cluster_setting

  # Cluster Cloudwatch log group
  create_cloudwatch_log_group            = var.create_cloudwatch_log_group
  cloudwatch_log_group_name              = var.cloudwatch_log_group_name
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = var.cloudwatch_log_group_kms_key_id
  cloudwatch_log_group_class             = var.cloudwatch_log_group_class
  cloudwatch_log_group_tags              = var.cloudwatch_log_group_tags

  # Cluster capacity providers
  autoscaling_capacity_providers     = var.autoscaling_capacity_providers
  default_capacity_provider_strategy = var.default_capacity_provider_strategy

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

  for_each = var.create && var.services != null ? var.services : {}

  create         = each.value.create
  create_service = each.value.create_service
  region         = var.region

  # Service
  ignore_task_definition_changes     = each.value.ignore_task_definition_changes
  alarms                             = each.value.alarms
  availability_zone_rebalancing      = each.value.availability_zone_rebalancing
  capacity_provider_strategy         = each.value.capacity_provider_strategy
  cluster_arn                        = module.cluster.arn
  deployment_circuit_breaker         = each.value.deployment_circuit_breaker
  deployment_configuration           = each.value.deployment_configuration
  deployment_controller              = each.value.deployment_controller
  deployment_maximum_percent         = each.value.deployment_maximum_percent
  deployment_minimum_healthy_percent = each.value.deployment_minimum_healthy_percent
  desired_count                      = each.value.desired_count
  enable_ecs_managed_tags            = each.value.enable_ecs_managed_tags
  enable_execute_command             = each.value.enable_execute_command
  force_delete                       = each.value.force_delete
  force_new_deployment               = each.value.force_new_deployment
  health_check_grace_period_seconds  = each.value.health_check_grace_period_seconds
  launch_type                        = each.value.launch_type
  load_balancer                      = each.value.load_balancer
  name                               = coalesce(each.value.name, each.key)
  assign_public_ip                   = each.value.assign_public_ip
  security_group_ids                 = each.value.security_group_ids
  subnet_ids                         = each.value.subnet_ids
  ordered_placement_strategy         = each.value.ordered_placement_strategy
  placement_constraints              = each.value.placement_constraints
  platform_version                   = each.value.platform_version
  propagate_tags                     = each.value.propagate_tags
  scheduling_strategy                = each.value.scheduling_strategy
  service_connect_configuration      = each.value.service_connect_configuration
  service_registries                 = each.value.service_registries
  sigint_rollback                    = each.value.sigint_rollback
  timeouts                           = each.value.timeouts
  triggers                           = each.value.triggers
  volume_configuration               = each.value.volume_configuration
  vpc_lattice_configurations         = each.value.vpc_lattice_configurations
  wait_for_steady_state              = each.value.wait_for_steady_state
  service_tags                       = each.value.service_tags

  # Service IAM role
  create_iam_role               = each.value.create_iam_role
  iam_role_arn                  = each.value.iam_role_arn
  iam_role_name                 = each.value.iam_role_name
  iam_role_use_name_prefix      = each.value.iam_role_use_name_prefix
  iam_role_path                 = each.value.iam_role_path
  iam_role_description          = each.value.iam_role_description
  iam_role_permissions_boundary = each.value.iam_role_permissions_boundary
  iam_role_tags                 = each.value.iam_role_tags
  iam_role_statements           = each.value.iam_role_statements

  # Task definition
  create_task_definition                = each.value.create_task_definition
  task_definition_arn                   = each.value.task_definition_arn
  container_definitions                 = each.value.container_definitions
  cpu                                   = each.value.cpu
  enable_fault_injection                = each.value.enable_fault_injection
  ephemeral_storage                     = each.value.ephemeral_storage
  family                                = each.value.family
  ipc_mode                              = each.value.ipc_mode
  memory                                = each.value.memory
  network_mode                          = each.value.network_mode
  pid_mode                              = each.value.pid_mode
  proxy_configuration                   = each.value.proxy_configuration
  requires_compatibilities              = each.value.requires_compatibilities
  runtime_platform                      = each.value.runtime_platform
  skip_destroy                          = each.value.skip_destroy
  task_definition_placement_constraints = each.value.task_definition_placement_constraints
  track_latest                          = each.value.track_latest
  volume                                = each.value.volume
  task_tags                             = each.value.task_tags

  # Task Execution IAM role
  create_task_exec_iam_role               = each.value.create_task_exec_iam_role
  task_exec_iam_role_arn                  = try(coalesce(each.value.task_exec_iam_role_arn, module.cluster.task_exec_iam_role_arn), null)
  task_exec_iam_role_name                 = each.value.task_exec_iam_role_name
  task_exec_iam_role_use_name_prefix      = each.value.task_exec_iam_role_use_name_prefix
  task_exec_iam_role_path                 = each.value.task_exec_iam_role_path
  task_exec_iam_role_description          = each.value.task_exec_iam_role_description
  task_exec_iam_role_permissions_boundary = each.value.task_exec_iam_role_permissions_boundary
  task_exec_iam_role_tags                 = each.value.task_exec_iam_role_tags
  task_exec_iam_role_policies             = each.value.task_exec_iam_role_policies
  task_exec_iam_role_max_session_duration = each.value.task_exec_iam_role_max_session_duration

  # Task execution IAM role policy
  create_task_exec_policy   = each.value.create_task_exec_policy
  task_exec_ssm_param_arns  = each.value.task_exec_ssm_param_arns
  task_exec_secret_arns     = each.value.task_exec_secret_arns
  task_exec_iam_statements  = each.value.task_exec_iam_statements
  task_exec_iam_policy_path = each.value.task_exec_iam_policy_path

  # Tasks - IAM role
  create_tasks_iam_role               = each.value.create_tasks_iam_role
  tasks_iam_role_arn                  = each.value.tasks_iam_role_arn
  tasks_iam_role_name                 = each.value.tasks_iam_role_name
  tasks_iam_role_use_name_prefix      = each.value.tasks_iam_role_use_name_prefix
  tasks_iam_role_path                 = each.value.tasks_iam_role_path
  tasks_iam_role_description          = each.value.tasks_iam_role_description
  tasks_iam_role_permissions_boundary = each.value.tasks_iam_role_permissions_boundary
  tasks_iam_role_tags                 = each.value.tasks_iam_role_tags
  tasks_iam_role_policies             = each.value.tasks_iam_role_policies
  tasks_iam_role_statements           = each.value.tasks_iam_role_statements

  # Task set
  external_id               = each.value.external_id
  scale                     = each.value.scale
  wait_until_stable         = each.value.wait_until_stable
  wait_until_stable_timeout = each.value.wait_until_stable_timeout

  # Autoscaling
  enable_autoscaling            = each.value.enable_autoscaling
  autoscaling_min_capacity      = each.value.autoscaling_min_capacity
  autoscaling_max_capacity      = each.value.autoscaling_max_capacity
  autoscaling_policies          = each.value.autoscaling_policies
  autoscaling_scheduled_actions = each.value.autoscaling_scheduled_actions

  # Security Group
  create_security_group          = each.value.create_security_group
  vpc_id                         = each.value.vpc_id
  security_group_name            = each.value.security_group_name
  security_group_use_name_prefix = each.value.security_group_use_name_prefix
  security_group_description     = each.value.security_group_description
  security_group_ingress_rules   = each.value.security_group_ingress_rules
  security_group_egress_rules    = each.value.security_group_egress_rules
  security_group_tags            = each.value.security_group_tags

  # ECS infrastructure IAM role
  create_infrastructure_iam_role               = each.value.create_infrastructure_iam_role
  infrastructure_iam_role_arn                  = each.value.infrastructure_iam_role_arn
  infrastructure_iam_role_name                 = each.value.infrastructure_iam_role_name
  infrastructure_iam_role_use_name_prefix      = each.value.infrastructure_iam_role_use_name_prefix
  infrastructure_iam_role_path                 = each.value.infrastructure_iam_role_path
  infrastructure_iam_role_description          = each.value.infrastructure_iam_role_description
  infrastructure_iam_role_permissions_boundary = each.value.infrastructure_iam_role_permissions_boundary
  infrastructure_iam_role_tags                 = each.value.infrastructure_iam_role_tags

  tags = merge(var.tags, each.value.tags)
}
