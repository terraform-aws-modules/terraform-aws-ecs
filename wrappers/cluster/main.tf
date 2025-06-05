module "wrapper" {
  source = "../../modules/cluster"

  for_each = var.items

  autoscaling_capacity_providers         = try(each.value.autoscaling_capacity_providers, var.defaults.autoscaling_capacity_providers, {})
  cloudwatch_log_group_kms_key_id        = try(each.value.cloudwatch_log_group_kms_key_id, var.defaults.cloudwatch_log_group_kms_key_id, null)
  cloudwatch_log_group_name              = try(each.value.cloudwatch_log_group_name, var.defaults.cloudwatch_log_group_name, null)
  cloudwatch_log_group_retention_in_days = try(each.value.cloudwatch_log_group_retention_in_days, var.defaults.cloudwatch_log_group_retention_in_days, 90)
  cloudwatch_log_group_tags              = try(each.value.cloudwatch_log_group_tags, var.defaults.cloudwatch_log_group_tags, {})
  configuration = try(each.value.configuration, var.defaults.configuration, {
    execute_command_configuration = {
      log_configuration = {
        cloud_watch_log_group_name = "placeholder"
      }
    }
  })
  create                                = try(each.value.create, var.defaults.create, true)
  create_cloudwatch_log_group           = try(each.value.create_cloudwatch_log_group, var.defaults.create_cloudwatch_log_group, true)
  create_task_exec_iam_role             = try(each.value.create_task_exec_iam_role, var.defaults.create_task_exec_iam_role, false)
  create_task_exec_policy               = try(each.value.create_task_exec_policy, var.defaults.create_task_exec_policy, true)
  default_capacity_provider_use_fargate = try(each.value.default_capacity_provider_use_fargate, var.defaults.default_capacity_provider_use_fargate, true)
  fargate_capacity_providers            = try(each.value.fargate_capacity_providers, var.defaults.fargate_capacity_providers, {})
  name                                  = try(each.value.name, var.defaults.name, "")
  service_connect_defaults              = try(each.value.service_connect_defaults, var.defaults.service_connect_defaults, null)
  settings = try(each.value.settings, var.defaults.settings, [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ])
  tags                                    = try(each.value.tags, var.defaults.tags, {})
  task_exec_iam_role_description          = try(each.value.task_exec_iam_role_description, var.defaults.task_exec_iam_role_description, null)
  task_exec_iam_role_name                 = try(each.value.task_exec_iam_role_name, var.defaults.task_exec_iam_role_name, null)
  task_exec_iam_role_path                 = try(each.value.task_exec_iam_role_path, var.defaults.task_exec_iam_role_path, null)
  task_exec_iam_role_permissions_boundary = try(each.value.task_exec_iam_role_permissions_boundary, var.defaults.task_exec_iam_role_permissions_boundary, null)
  task_exec_iam_role_policies             = try(each.value.task_exec_iam_role_policies, var.defaults.task_exec_iam_role_policies, {})
  task_exec_iam_role_tags                 = try(each.value.task_exec_iam_role_tags, var.defaults.task_exec_iam_role_tags, {})
  task_exec_iam_role_use_name_prefix      = try(each.value.task_exec_iam_role_use_name_prefix, var.defaults.task_exec_iam_role_use_name_prefix, true)
  task_exec_iam_statements                = try(each.value.task_exec_iam_statements, var.defaults.task_exec_iam_statements, {})
  task_exec_secret_arns                   = try(each.value.task_exec_secret_arns, var.defaults.task_exec_secret_arns, ["arn:aws:secretsmanager:*:*:secret:*"])
  task_exec_ssm_param_arns                = try(each.value.task_exec_ssm_param_arns, var.defaults.task_exec_ssm_param_arns, ["arn:aws:ssm:*:*:parameter/*"])
}
