module "wrapper" {
  source = "../"

  for_each = var.items

  capacity_providers                     = try(each.value.capacity_providers, var.defaults.capacity_providers, null)
  cloudwatch_log_group_class             = try(each.value.cloudwatch_log_group_class, var.defaults.cloudwatch_log_group_class, null)
  cloudwatch_log_group_kms_key_id        = try(each.value.cloudwatch_log_group_kms_key_id, var.defaults.cloudwatch_log_group_kms_key_id, null)
  cloudwatch_log_group_name              = try(each.value.cloudwatch_log_group_name, var.defaults.cloudwatch_log_group_name, null)
  cloudwatch_log_group_retention_in_days = try(each.value.cloudwatch_log_group_retention_in_days, var.defaults.cloudwatch_log_group_retention_in_days, 90)
  cloudwatch_log_group_tags              = try(each.value.cloudwatch_log_group_tags, var.defaults.cloudwatch_log_group_tags, {})
  cluster_capacity_providers             = try(each.value.cluster_capacity_providers, var.defaults.cluster_capacity_providers, [])
  cluster_configuration = try(each.value.cluster_configuration, var.defaults.cluster_configuration, {
    execute_command_configuration = {
      log_configuration = {
        cloud_watch_log_group_name = "placeholder"
      }
    }
  })
  cluster_name                     = try(each.value.cluster_name, var.defaults.cluster_name, "")
  cluster_service_connect_defaults = try(each.value.cluster_service_connect_defaults, var.defaults.cluster_service_connect_defaults, null)
  cluster_setting = try(each.value.cluster_setting, var.defaults.cluster_setting, [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ])
  cluster_tags                                      = try(each.value.cluster_tags, var.defaults.cluster_tags, {})
  create                                            = try(each.value.create, var.defaults.create, true)
  create_cloudwatch_log_group                       = try(each.value.create_cloudwatch_log_group, var.defaults.create_cloudwatch_log_group, true)
  create_infrastructure_iam_role                    = try(each.value.create_infrastructure_iam_role, var.defaults.create_infrastructure_iam_role, true)
  create_node_iam_instance_profile                  = try(each.value.create_node_iam_instance_profile, var.defaults.create_node_iam_instance_profile, true)
  create_security_group                             = try(each.value.create_security_group, var.defaults.create_security_group, true)
  create_task_exec_iam_role                         = try(each.value.create_task_exec_iam_role, var.defaults.create_task_exec_iam_role, false)
  create_task_exec_policy                           = try(each.value.create_task_exec_policy, var.defaults.create_task_exec_policy, true)
  default_capacity_provider_strategy                = try(each.value.default_capacity_provider_strategy, var.defaults.default_capacity_provider_strategy, null)
  disable_v7_default_name_description               = try(each.value.disable_v7_default_name_description, var.defaults.disable_v7_default_name_description, false)
  infrastructure_iam_role_description               = try(each.value.infrastructure_iam_role_description, var.defaults.infrastructure_iam_role_description, null)
  infrastructure_iam_role_name                      = try(each.value.infrastructure_iam_role_name, var.defaults.infrastructure_iam_role_name, null)
  infrastructure_iam_role_override_policy_documents = try(each.value.infrastructure_iam_role_override_policy_documents, var.defaults.infrastructure_iam_role_override_policy_documents, [])
  infrastructure_iam_role_path                      = try(each.value.infrastructure_iam_role_path, var.defaults.infrastructure_iam_role_path, null)
  infrastructure_iam_role_permissions_boundary      = try(each.value.infrastructure_iam_role_permissions_boundary, var.defaults.infrastructure_iam_role_permissions_boundary, null)
  infrastructure_iam_role_source_policy_documents   = try(each.value.infrastructure_iam_role_source_policy_documents, var.defaults.infrastructure_iam_role_source_policy_documents, [])
  infrastructure_iam_role_statements                = try(each.value.infrastructure_iam_role_statements, var.defaults.infrastructure_iam_role_statements, null)
  infrastructure_iam_role_tags                      = try(each.value.infrastructure_iam_role_tags, var.defaults.infrastructure_iam_role_tags, {})
  infrastructure_iam_role_use_name_prefix           = try(each.value.infrastructure_iam_role_use_name_prefix, var.defaults.infrastructure_iam_role_use_name_prefix, true)
  node_iam_role_additional_policies                 = try(each.value.node_iam_role_additional_policies, var.defaults.node_iam_role_additional_policies, {})
  node_iam_role_description                         = try(each.value.node_iam_role_description, var.defaults.node_iam_role_description, "ECS Managed Instances node IAM role")
  node_iam_role_name                                = try(each.value.node_iam_role_name, var.defaults.node_iam_role_name, null)
  node_iam_role_override_policy_documents           = try(each.value.node_iam_role_override_policy_documents, var.defaults.node_iam_role_override_policy_documents, [])
  node_iam_role_path                                = try(each.value.node_iam_role_path, var.defaults.node_iam_role_path, null)
  node_iam_role_permissions_boundary                = try(each.value.node_iam_role_permissions_boundary, var.defaults.node_iam_role_permissions_boundary, null)
  node_iam_role_source_policy_documents             = try(each.value.node_iam_role_source_policy_documents, var.defaults.node_iam_role_source_policy_documents, [])
  node_iam_role_statements                          = try(each.value.node_iam_role_statements, var.defaults.node_iam_role_statements, null)
  node_iam_role_tags                                = try(each.value.node_iam_role_tags, var.defaults.node_iam_role_tags, {})
  node_iam_role_use_name_prefix                     = try(each.value.node_iam_role_use_name_prefix, var.defaults.node_iam_role_use_name_prefix, true)
  region                                            = try(each.value.region, var.defaults.region, null)
  security_group_description                        = try(each.value.security_group_description, var.defaults.security_group_description, null)
  security_group_egress_rules = try(each.value.security_group_egress_rules, var.defaults.security_group_egress_rules, {
    all_ipv4 = {
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all IPv4 traffic"
      ip_protocol = "-1"
    }
    all_ipv6 = {
      cidr_ipv6   = "::/0"
      description = "Allow all IPv6 traffic"
      ip_protocol = "-1"
    }
  })
  security_group_ingress_rules            = try(each.value.security_group_ingress_rules, var.defaults.security_group_ingress_rules, {})
  security_group_name                     = try(each.value.security_group_name, var.defaults.security_group_name, null)
  security_group_tags                     = try(each.value.security_group_tags, var.defaults.security_group_tags, {})
  security_group_use_name_prefix          = try(each.value.security_group_use_name_prefix, var.defaults.security_group_use_name_prefix, true)
  services                                = try(each.value.services, var.defaults.services, null)
  tags                                    = try(each.value.tags, var.defaults.tags, {})
  task_exec_iam_role_description          = try(each.value.task_exec_iam_role_description, var.defaults.task_exec_iam_role_description, null)
  task_exec_iam_role_name                 = try(each.value.task_exec_iam_role_name, var.defaults.task_exec_iam_role_name, null)
  task_exec_iam_role_path                 = try(each.value.task_exec_iam_role_path, var.defaults.task_exec_iam_role_path, null)
  task_exec_iam_role_permissions_boundary = try(each.value.task_exec_iam_role_permissions_boundary, var.defaults.task_exec_iam_role_permissions_boundary, null)
  task_exec_iam_role_policies             = try(each.value.task_exec_iam_role_policies, var.defaults.task_exec_iam_role_policies, {})
  task_exec_iam_role_tags                 = try(each.value.task_exec_iam_role_tags, var.defaults.task_exec_iam_role_tags, {})
  task_exec_iam_role_use_name_prefix      = try(each.value.task_exec_iam_role_use_name_prefix, var.defaults.task_exec_iam_role_use_name_prefix, true)
  task_exec_iam_statements                = try(each.value.task_exec_iam_statements, var.defaults.task_exec_iam_statements, null)
  task_exec_secret_arns                   = try(each.value.task_exec_secret_arns, var.defaults.task_exec_secret_arns, [])
  task_exec_ssm_param_arns                = try(each.value.task_exec_ssm_param_arns, var.defaults.task_exec_ssm_param_arns, [])
  vpc_id                                  = try(each.value.vpc_id, var.defaults.vpc_id, null)
}
