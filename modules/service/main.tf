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
    for_each = var.alarms != null ? [var.alarms] : []

    content {
      alarm_names = alarms.value.alarm_names
      enable      = alarms.value.enable
      rollback    = alarms.value.rollback
    }
  }

  availability_zone_rebalancing = var.availability_zone_rebalancing

  dynamic "capacity_provider_strategy" {
    # Set by task set if deployment controller is external
    for_each = !local.is_external_deployment && var.capacity_provider_strategy != null ? var.capacity_provider_strategy : {}

    content {
      base              = capacity_provider_strategy.value.base
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }

  cluster = var.cluster_arn

  dynamic "deployment_circuit_breaker" {
    for_each = var.deployment_circuit_breaker != null ? [var.deployment_circuit_breaker] : []

    content {
      enable   = deployment_circuit_breaker.value.enable
      rollback = deployment_circuit_breaker.value.rollback
    }
  }

  dynamic "deployment_controller" {
    for_each = var.deployment_controller != null ? [var.deployment_controller] : []

    content {
      type = deployment_controller.value.type
    }
  }

  deployment_maximum_percent         = local.is_daemon || local.is_external_deployment ? null : var.deployment_maximum_percent
  deployment_minimum_healthy_percent = local.is_daemon || local.is_external_deployment ? null : var.deployment_minimum_healthy_percent
  desired_count                      = local.is_daemon || local.is_external_deployment ? null : var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  enable_execute_command             = var.enable_execute_command
  force_delete                       = var.force_delete
  force_new_deployment               = local.is_external_deployment ? null : var.force_new_deployment
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  iam_role                           = local.iam_role_arn
  launch_type                        = local.is_external_deployment || var.capacity_provider_strategy != null ? null : var.launch_type

  dynamic "load_balancer" {
    # Set by task set if deployment controller is external
    for_each = var.load_balancer != null ? var.load_balancer : {}

    content {
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
      elb_name         = load_balancer.value.elb_name
      target_group_arn = load_balancer.value.target_group_arn
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
    for_each = var.ordered_placement_strategy != null ? var.ordered_placement_strategy : {}

    content {
      field = ordered_placement_strategy.value.field
      type  = ordered_placement_strategy.value.type
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints != null ? var.placement_constraints : {}

    content {
      expression = placement_constraints.value.expression
      type       = placement_constraints.value.type
    }
  }

  # Set by task set if deployment controller is external
  platform_version    = local.is_fargate && !local.is_external_deployment ? var.platform_version : null
  propagate_tags      = var.propagate_tags
  scheduling_strategy = local.is_fargate ? "REPLICA" : var.scheduling_strategy

  dynamic "service_connect_configuration" {
    for_each = var.service_connect_configuration != null ? [var.service_connect_configuration] : []

    content {
      enabled = service_connect_configuration.value.enabled

      dynamic "log_configuration" {
        for_each = service_connect_configuration.value.log_configuration != null ? [service_connect_configuration.value.log_configuration] : []

        content {
          log_driver = log_configuration.value.log_driver
          options    = log_configuration.value.options

          dynamic "secret_option" {
            for_each = log_configuration.value.secret_option != null ? [log_configuration.value.secret_option] : []

            content {
              name       = secret_option.value.name
              value_from = secret_option.value.value_from
            }
          }
        }
      }

      namespace = service_connect_configuration.value.namespace

      dynamic "service" {
        for_each = service_connect_configuration.value.service != null ? service_connect_configuration.value.service : []

        content {
          dynamic "client_alias" {
            for_each = service.value.client_alias != null ? [service.value.client_alias] : []

            content {
              dns_name = client_alias.value.dns_name
              port     = client_alias.value.port
            }
          }

          discovery_name        = service.value.discovery_name
          ingress_port_override = service.value.ingress_port_override
          port_name             = service.value.port_name

          dynamic "timeout" {
            for_each = service.value.timeout != null ? [service.value.timeout] : []

            content {
              idle_timeout_seconds        = timeout.value.idle_timeout_seconds
              per_request_timeout_seconds = timeout.value.per_request_timeout_seconds
            }
          }

          dynamic "tls" {
            for_each = service.value.tls != null ? [service.value.tls] : []

            content {
              dynamic "issuer_cert_authority" {
                for_each = tls.value.issuer_cert_authority

                content {
                  aws_pca_authority_arn = issuer_cert_authority.value.aws_pca_authority_arn
                }
              }

              kms_key  = tls.value.kms_key
              role_arn = tls.value.role_arn
            }
          }
        }
      }
    }
  }

  dynamic "service_registries" {
    # Set by task set if deployment controller is external
    for_each = var.service_registries != null && !local.is_external_deployment ? [var.service_registries] : []

    content {
      container_name = service_registries.value.container_name
      container_port = service_registries.value.container_port
      port           = service_registries.value.port
      registry_arn   = service_registries.value.registry_arn
    }
  }

  tags            = merge(var.tags, var.service_tags)
  task_definition = local.task_definition
  triggers        = var.triggers

  dynamic "volume_configuration" {
    for_each = var.volume_configuration != null ? [var.volume_configuration] : []

    content {
      name = volume_configuration.value.name

      dynamic "managed_ebs_volume" {
        for_each = volume_configuration.value.managed_ebs_volume

        content {
          encrypted        = managed_ebs_volume.value.encrypted
          file_system_type = managed_ebs_volume.value.file_system_type
          iops             = managed_ebs_volume.value.iops
          kms_key_id       = managed_ebs_volume.value.kms_key_id
          role_arn         = local.infrastructure_iam_role_arn
          size_in_gb       = managed_ebs_volume.value.size_in_gb
          snapshot_id      = managed_ebs_volume.value.snapshot_id
          throughput       = managed_ebs_volume.value.throughput
          volume_type      = managed_ebs_volume.value.volume_type

          dynamic "tag_specifications" {
            for_each = managed_ebs_volume.value.tag_specifications != null ? managed_ebs_volume.value.tag_specifications : []

            content {
              resource_type  = tag_specifications.value.resource_type
              propagate_tags = tag_specifications.value.propagate_tags
              tags           = tag_specifications.value.tags
            }
          }
        }
      }
    }
  }

  dynamic "vpc_lattice_configurations" {
    for_each = var.vpc_lattice_configurations != null ? [var.vpc_lattice_configurations] : []

    content {
      role_arn         = local.infrastructure_iam_role_arn
      target_group_arn = vpc_lattice_configurations.value.target_group_arn
      port_name        = vpc_lattice_configurations.value.port_name
    }
  }

  wait_for_steady_state = var.wait_for_steady_state

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.service,
    aws_iam_role_policy_attachment.infrastructure_iam_role_ebs_policy,
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
    for_each = var.alarms != null ? [var.alarms] : []

    content {
      alarm_names = alarms.value.alarm_names
      enable      = alarms.value.enable
      rollback    = alarms.value.rollback
    }
  }

  availability_zone_rebalancing = var.availability_zone_rebalancing

  dynamic "capacity_provider_strategy" {
    # Set by task set if deployment controller is external
    for_each = !local.is_external_deployment && var.capacity_provider_strategy != null ? var.capacity_provider_strategy : {}

    content {
      base              = capacity_provider_strategy.value.base
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }

  cluster = var.cluster_arn

  dynamic "deployment_circuit_breaker" {
    for_each = var.deployment_circuit_breaker != null ? [var.deployment_circuit_breaker] : []

    content {
      enable   = deployment_circuit_breaker.value.enable
      rollback = deployment_circuit_breaker.value.rollback
    }
  }

  dynamic "deployment_controller" {
    for_each = var.deployment_controller != null ? [var.deployment_controller] : []

    content {
      type = deployment_controller.value.type
    }
  }

  deployment_maximum_percent         = local.is_daemon || local.is_external_deployment ? null : var.deployment_maximum_percent
  deployment_minimum_healthy_percent = local.is_daemon || local.is_external_deployment ? null : var.deployment_minimum_healthy_percent
  desired_count                      = local.is_daemon || local.is_external_deployment ? null : var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  enable_execute_command             = var.enable_execute_command
  force_delete                       = var.force_delete
  force_new_deployment               = local.is_external_deployment ? null : var.force_new_deployment
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  iam_role                           = local.iam_role_arn
  launch_type                        = local.is_external_deployment || var.capacity_provider_strategy != null ? null : var.launch_type

  dynamic "load_balancer" {
    # Set by task set if deployment controller is external
    for_each = var.load_balancer != null ? var.load_balancer : {}

    content {
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
      elb_name         = load_balancer.value.elb_name
      target_group_arn = load_balancer.value.target_group_arn
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
    for_each = var.ordered_placement_strategy != null ? var.ordered_placement_strategy : {}

    content {
      field = ordered_placement_strategy.value.field
      type  = ordered_placement_strategy.value.type
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints != null ? var.placement_constraints : {}

    content {
      expression = placement_constraints.value.expression
      type       = placement_constraints.value.type
    }
  }

  # Set by task set if deployment controller is external
  platform_version    = local.is_fargate && !local.is_external_deployment ? var.platform_version : null
  propagate_tags      = var.propagate_tags
  scheduling_strategy = local.is_fargate ? "REPLICA" : var.scheduling_strategy

  dynamic "service_connect_configuration" {
    for_each = var.service_connect_configuration != null ? [var.service_connect_configuration] : []

    content {
      enabled = service_connect_configuration.value.enabled

      dynamic "log_configuration" {
        for_each = service_connect_configuration.value.log_configuration != null ? [service_connect_configuration.value.log_configuration] : []

        content {
          log_driver = log_configuration.value.log_driver
          options    = log_configuration.value.options

          dynamic "secret_option" {
            for_each = log_configuration.value.secret_option != null ? [log_configuration.value.secret_option] : []

            content {
              name       = secret_option.value.name
              value_from = secret_option.value.value_from
            }
          }
        }
      }

      namespace = service_connect_configuration.value.namespace

      dynamic "service" {
        for_each = service_connect_configuration.value.service != null ? service_connect_configuration.value.service : []

        content {
          dynamic "client_alias" {
            for_each = service.value.client_alias != null ? [service.value.client_alias] : []

            content {
              dns_name = client_alias.value.dns_name
              port     = client_alias.value.port
            }
          }

          discovery_name        = service.value.discovery_name
          ingress_port_override = service.value.ingress_port_override
          port_name             = service.value.port_name

          dynamic "timeout" {
            for_each = service.value.timeout != null ? [service.value.timeout] : []

            content {
              idle_timeout_seconds        = timeout.value.idle_timeout_seconds
              per_request_timeout_seconds = timeout.value.per_request_timeout_seconds
            }
          }

          dynamic "tls" {
            for_each = service.value.tls != null ? [service.value.tls] : []

            content {
              dynamic "issuer_cert_authority" {
                for_each = tls.value.issuer_cert_authority

                content {
                  aws_pca_authority_arn = issuer_cert_authority.value.aws_pca_authority_arn
                }
              }

              kms_key  = tls.value.kms_key
              role_arn = tls.value.role_arn
            }
          }
        }
      }
    }
  }

  dynamic "service_registries" {
    # Set by task set if deployment controller is external
    for_each = var.service_registries != null && !local.is_external_deployment ? [var.service_registries] : []

    content {
      container_name = service_registries.value.container_name
      container_port = service_registries.value.container_port
      port           = service_registries.value.port
      registry_arn   = service_registries.value.registry_arn
    }
  }

  tags            = merge(var.tags, var.service_tags)
  task_definition = local.task_definition
  triggers        = var.triggers

  dynamic "volume_configuration" {
    for_each = var.volume_configuration != null ? [var.volume_configuration] : []

    content {
      name = volume_configuration.value.name

      dynamic "managed_ebs_volume" {
        for_each = volume_configuration.value.managed_ebs_volume

        content {
          encrypted        = managed_ebs_volume.value.encrypted
          file_system_type = managed_ebs_volume.value.file_system_type
          iops             = managed_ebs_volume.value.iops
          kms_key_id       = managed_ebs_volume.value.kms_key_id
          role_arn         = local.infrastructure_iam_role_arn
          size_in_gb       = managed_ebs_volume.value.size_in_gb
          snapshot_id      = managed_ebs_volume.value.snapshot_id
          throughput       = managed_ebs_volume.value.throughput
          volume_type      = managed_ebs_volume.value.volume_type

          dynamic "tag_specifications" {
            for_each = managed_ebs_volume.value.tag_specifications != null ? managed_ebs_volume.value.tag_specifications : []

            content {
              resource_type  = tag_specifications.value.resource_type
              propagate_tags = tag_specifications.value.propagate_tags
              tags           = tag_specifications.value.tags
            }
          }
        }
      }
    }
  }

  dynamic "vpc_lattice_configurations" {
    for_each = var.vpc_lattice_configurations != null ? [var.vpc_lattice_configurations] : []

    content {
      role_arn         = local.infrastructure_iam_role_arn
      target_group_arn = vpc_lattice_configurations.value.target_group_arn
      port_name        = vpc_lattice_configurations.value.port_name
    }
  }

  wait_for_steady_state = var.wait_for_steady_state

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.service,
    aws_iam_role_policy_attachment.infrastructure_iam_role_ebs_policy,
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
  needs_iam_role  = var.network_mode != "awsvpc" && var.load_balancer != null
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
    for_each = var.iam_role_statements != null ? var.iam_role_statements : []

    content {
      sid           = statement.value.sid
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
        for_each = statement.value.conditions != null ? statement.value.conditions : []

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
  command                = try(each.value.command, var.container_definition_defaults.command, null)
  cpu                    = try(each.value.cpu, var.container_definition_defaults.cpu, null)
  dependsOn              = try(each.value.dependsOn, var.container_definition_defaults.dependsOn, null)
  disableNetworking      = try(each.value.disableNetworking, var.container_definition_defaults.disableNetworking, null)
  dnsSearchDomains       = try(each.value.dnsSearchDomains, var.container_definition_defaults.dnsSearchDomains, null)
  dnsServers             = try(each.value.dnsServers, var.container_definition_defaults.dnsServers, null)
  dockerLabels           = try(each.value.dockerLabels, var.container_definition_defaults.dockerLabels, null)
  dockerSecurityOptions  = try(each.value.dockerSecurityOptions, var.container_definition_defaults.dockerSecurityOptions, null)
  enable_execute_command = try(each.value.enable_execute_command, var.container_definition_defaults.enable_execute_command, var.enable_execute_command)
  entrypoint             = try(each.value.entrypoint, var.container_definition_defaults.entrypoint, null)
  environment            = try(each.value.environment, var.container_definition_defaults.environment, null)
  environmentFiles       = try(each.value.environmentFiles, var.container_definition_defaults.environmentFiles, null)
  essential              = try(each.value.essential, var.container_definition_defaults.essential, null)
  extraHosts             = try(each.value.extraHosts, var.container_definition_defaults.extraHosts, null)
  firelensConfiguration  = try(each.value.firelensConfiguration, var.container_definition_defaults.firelensConfiguration, null)
  healthCheck            = try(each.value.healthCheck, var.container_definition_defaults.healthCheck, null)
  hostname               = try(each.value.hostname, var.container_definition_defaults.hostname, null)
  image                  = try(each.value.image, var.container_definition_defaults.image, null)
  interactive            = try(each.value.interactive, var.container_definition_defaults.interactive, false)
  links                  = try(each.value.links, var.container_definition_defaults.links, null)
  linuxParameters        = try(each.value.linuxParameters, var.container_definition_defaults.linuxParameters, { initProcessEnabled = false })
  logConfiguration       = try(each.value.logConfiguration, var.container_definition_defaults.logConfiguration, {})
  memory                 = try(each.value.memory, var.container_definition_defaults.memory, null)
  memoryReservation      = try(each.value.memory_reservation, var.container_definition_defaults.memoryReservation, null)
  mountPoints            = try(each.value.mount_points, var.container_definition_defaults.mountPoints, null)
  name                   = try(each.value.name, each.key)
  portMappings           = try(each.value.port_mappings, var.container_definition_defaults.portMappings, null)
  privileged             = try(each.value.privileged, var.container_definition_defaults.privileged, false)
  pseudoTerminal         = try(each.value.pseudoTerminal, var.container_definition_defaults.pseudoTerminal, false)
  readonlyRootFilesystem = try(each.value.readonlyRootFilesystem, var.container_definition_defaults.readonlyRootFilesystem, true)
  repositoryCredentials  = try(each.value.repositoryCredentials, var.container_definition_defaults.repositoryCredentials, null)
  resourceRequirements   = try(each.value.resourceRequirements, var.container_definition_defaults.resourceRequirements, null)
  restartPolicy          = try(each.value.restartPolicy, var.container_definition_defaults.restartPolicy, { enabled = true })
  secrets                = try(each.value.secrets, var.container_definition_defaults.secrets, null)
  startTimeout           = try(each.value.startTimeout, var.container_definition_defaults.startTimeout, 30)
  stopTimeout            = try(each.value.stopTimeout, var.container_definition_defaults.stopTimeout, 120)
  systemControls         = try(each.value.systemControls, var.container_definition_defaults.systemControls, null)
  ulimits                = try(each.value.ulimits, var.container_definition_defaults.ulimits, null)
  user                   = try(each.value.user, var.container_definition_defaults.user, null)
  volumesFrom            = try(each.value.volumesFrom, var.container_definition_defaults.volumesFrom, null)
  workingDirectory       = try(each.value.workingDirectory, var.container_definition_defaults.workingDirectory, null)

  # CloudWatch Log Group
  service                                = var.name
  enable_cloudwatch_logging              = try(each.value.enable_cloudwatch_logging, var.container_definition_defaults.enable_cloudwatch_logging, true)
  create_cloudwatch_log_group            = try(each.value.create_cloudwatch_log_group, var.container_definition_defaults.create_cloudwatch_log_group, true)
  cloudwatch_log_group_name              = try(each.value.cloudwatch_log_group_name, var.container_definition_defaults.cloudwatch_log_group_name, null)
  cloudwatch_log_group_use_name_prefix   = try(each.value.cloudwatch_log_group_use_name_prefix, var.container_definition_defaults.cloudwatch_log_group_use_name_prefix, false)
  cloudwatch_log_group_class             = try(each.value.cloudwatch_log_group_class, var.container_definition_defaults.cloudwatch_log_group_class, null)
  cloudwatch_log_group_retention_in_days = try(each.value.cloudwatch_log_group_retention_in_days, var.container_definition_defaults.cloudwatch_log_group_retention_in_days, 14)
  cloudwatch_log_group_kms_key_id        = try(each.value.cloudwatch_log_group_kms_key_id, var.container_definition_defaults.cloudwatch_log_group_kms_key_id, null)

  tags = var.tags
}

################################################################################
# Task Definition
################################################################################

locals {
  create_task_definition = var.create && var.create_task_definition
  task_definition        = local.create_task_definition ? aws_ecs_task_definition.this[0].arn : var.task_definition_arn
}

resource "aws_ecs_task_definition" "this" {
  count = local.create_task_definition ? 1 : 0

  # Convert map of maps to array of maps before JSON encoding
  container_definitions = jsonencode([for k, v in module.container_definition : v.container_definition])
  cpu                   = var.cpu

  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage != null ? [var.ephemeral_storage] : []

    content {
      size_in_gib = ephemeral_storage.value.size_in_gib
    }
  }

  execution_role_arn = try(aws_iam_role.task_exec[0].arn, var.task_exec_iam_role_arn)
  family             = coalesce(var.family, var.name)

  dynamic "inference_accelerator" {
    for_each = var.inference_accelerator != null ? [var.inference_accelerator] : []

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
    for_each = var.task_definition_placement_constraints != null ? var.task_definition_placement_constraints : {}

    content {
      expression = placement_constraints.value.expression
      type       = placement_constraints.value.type
    }
  }

  dynamic "proxy_configuration" {
    for_each = var.proxy_configuration != null ? [var.proxy_configuration] : []

    content {
      container_name = proxy_configuration.value.container_name
      properties     = proxy_configuration.value.properties
      type           = proxy_configuration.value.type
    }
  }

  requires_compatibilities = var.requires_compatibilities

  dynamic "runtime_platform" {
    for_each = var.runtime_platform != null ? [var.runtime_platform] : []

    content {
      cpu_architecture        = runtime_platform.value.cpu_architecture
      operating_system_family = runtime_platform.value.operating_system_family
    }
  }

  skip_destroy  = var.skip_destroy
  task_role_arn = try(aws_iam_role.tasks[0].arn, var.tasks_iam_role_arn)
  track_latest  = var.track_latest

  dynamic "volume" {
    for_each = var.volume != null ? var.volume : {}

    content {
      dynamic "docker_volume_configuration" {
        for_each = volume.value.docker_volume_configuration != null ? [volume.value.docker_volume_configuration] : []

        content {
          autoprovision = docker_volume_configuration.value.autoprovision
          driver        = docker_volume_configuration.value.driver
          driver_opts   = docker_volume_configuration.value.driver_opts
          labels        = docker_volume_configuration.value.labels
          scope         = docker_volume_configuration.value.scope
        }
      }

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []

        content {
          dynamic "authorization_config" {
            for_each = efs_volume_configuration.value.authorization_config != null ? [efs_volume_configuration.value.authorization_config] : []

            content {
              access_point_id = authorization_config.value.access_point_id
              iam             = authorization_config.value.iam
            }
          }

          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = efs_volume_configuration.value.root_directory
          transit_encryption      = efs_volume_configuration.value.transit_encryption
          transit_encryption_port = efs_volume_configuration.value.transit_encryption_port
        }
      }

      dynamic "fsx_windows_file_server_volume_configuration" {
        for_each = volume.value.fsx_windows_file_server_volume_configuration != null ? [volume.value.fsx_windows_file_server_volume_configuration] : []

        content {
          dynamic "authorization_config" {
            for_each = fsx_windows_file_server_volume_configuration.value.authorization_config != null ? [fsx_windows_file_server_volume_configuration.value.authorization_config] : []

            content {
              credentials_parameter = authorization_config.value.credentials_parameter
              domain                = authorization_config.value.domain
            }
          }

          file_system_id = fsx_windows_file_server_volume_configuration.value.file_system_id
          root_directory = fsx_windows_file_server_volume_configuration.value.root_directory
        }
      }

      host_path           = volume.value.host_path
      configure_at_launch = volume.value.configure_at_launch
      name                = coalesce(volume.value.name, volume.key)
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
    for_each = var.task_exec_iam_statements != null ? var.task_exec_iam_statements : []

    content {
      sid           = statement.value.sid
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
        for_each = statement.value.conditions != null ? statement.value.conditions : []

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

  tags = merge(var.tags, var.task_exec_iam_role_tags)
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
  count = local.create_tasks_iam_role && (var.tasks_iam_role_statements != null || var.enable_execute_command) ? 1 : 0

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
    for_each = var.tasks_iam_role_statements != null ? var.tasks_iam_role_statements : []

    content {
      sid           = statement.value.sid
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
        for_each = statement.value.conditions != null ? statement.value.conditions : []

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_policy" "tasks" {
  count       = local.create_tasks_iam_role && (var.tasks_iam_role_statements != null || var.enable_execute_command) ? 1 : 0
  name        = var.tasks_iam_role_use_name_prefix ? null : local.tasks_iam_role_name
  name_prefix = var.tasks_iam_role_use_name_prefix ? "${local.tasks_iam_role_name}-" : null
  description = coalesce(var.tasks_iam_role_description, "Task role IAM policy")
  policy      = data.aws_iam_policy_document.tasks[0].json
  path        = var.tasks_iam_policy_path
  tags        = merge(var.tags, var.tasks_iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "tasks_policy" {
  count = local.create_tasks_iam_role && (length(var.tasks_iam_role_statements) > 0 || var.enable_execute_command) ? 1 : 0

  role       = aws_iam_role.tasks[0].name
  policy_arn = aws_iam_policy.tasks[0].arn
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
    for_each = var.load_balancer != null ? var.load_balancer : {}

    content {
      load_balancer_name = load_balancer.value.load_balancer_name
      target_group_arn   = load_balancer.value.target_group_arn
      container_name     = load_balancer.value.container_name
      container_port     = load_balancer.value.container_port
    }
  }

  dynamic "service_registries" {
    for_each = var.service_registries != null ? [var.service_registries] : []

    content {
      container_name = service_registries.value.container_name
      container_port = service_registries.value.container_port
      port           = service_registries.value.port
      registry_arn   = service_registries.value.registry_arn
    }
  }

  launch_type = var.capacity_provider_strategy != null ? null : var.launch_type

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy != null ? var.capacity_provider_strategy : {}

    content {
      base              = capacity_provider_strategy.value.base
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }

  platform_version = local.is_fargate ? var.platform_version : null

  dynamic "scale" {
    for_each = var.scale != null ? [var.scale] : []

    content {
      unit  = scale.value.unit
      value = scale.value.value
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
    for_each = var.load_balancer != null ? var.load_balancer : {}

    content {
      load_balancer_name = load_balancer.value.load_balancer_name
      target_group_arn   = load_balancer.value.target_group_arn
      container_name     = load_balancer.value.container_name
      container_port     = load_balancer.value.container_port
    }
  }

  dynamic "service_registries" {
    for_each = var.service_registries != null ? [var.service_registries] : []

    content {
      container_name = service_registries.value.container_name
      container_port = service_registries.value.container_port
      port           = service_registries.value.port
      registry_arn   = service_registries.value.registry_arn
    }
  }

  launch_type = var.capacity_provider_strategy != null ? null : var.launch_type

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy != null ? var.capacity_provider_strategy : {}

    content {
      base              = capacity_provider_strategy.value.base
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }

  platform_version = local.is_fargate ? var.platform_version : null

  dynamic "scale" {
    for_each = var.scale != null ? [var.scale] : []

    content {
      unit  = scale.value.unit
      value = scale.value.value
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
          dynamic "metrics" {
            for_each = try(customized_metric_specification.value.metrics, [])
            content {
              id          = metrics.value.id
              label       = try(metrics.value.label, null)
              return_data = try(metrics.value.return_data, true)
              expression  = try(metrics.value.expression, null)


              dynamic "metric_stat" {
                for_each = try([metrics.value.metric_stat], [])
                content {
                  stat = metric_stat.value.stat
                  dynamic "metric" {
                    for_each = try([metric_stat.value.metric], [])
                    content {
                      namespace   = metric.value.namespace
                      metric_name = metric.value.metric_name
                      dynamic "dimensions" {
                        for_each = try(metric.value.dimensions, [])
                        content {
                          name  = dimensions.value.name
                          value = dimensions.value.value
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          dynamic "dimensions" {
            for_each = try(customized_metric_specification.value.dimensions, [])

            content {
              name  = dimensions.value.name
              value = dimensions.value.value
            }
          }

          metric_name = try(customized_metric_specification.value.metric_name, null)
          namespace   = try(customized_metric_specification.value.namespace, null)
          statistic   = try(customized_metric_specification.value.statistic, null)
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
  for_each = local.enable_autoscaling && var.autoscaling_scheduled_actions != null ? var.autoscaling_scheduled_actions : {}

  name               = try(each.value.name, each.key)
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension

  scalable_target_action {
    min_capacity = each.value.min_capacity
    max_capacity = each.value.max_capacity
  }

  schedule   = each.value.schedule
  start_time = each.value.start_time
  end_time   = each.value.end_time
  timezone   = each.value.timezone
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

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.security_group_ingress_rules != null && local.create_security_group ? var.security_group_ingress_rules : {}

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = each.value.from_port
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  tags = merge(
    var.tags,
    { "Name" = try(each.value.name, "${local.security_group_name}-${each.key}") },
    var.security_group_tags,
    each.value.tags
  )
  to_port = try(coalesce(each.value.to_port, each.value.from_port), null)
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = var.security_group_egress_rules != null && local.create_security_group ? var.security_group_egress_rules : {}

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = try(coalesce(each.value.from_port, each.value.to_port), null)
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  tags = merge(
    var.tags,
    { "Name" = try(each.value.name, "${local.security_group_name}-${each.key}") },
    var.security_group_tags,
    each.value.tags
  )
  to_port = each.value.to_port
}

############################################################################################
# ECS infrastructure IAM role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/infrastructure_IAM_role.html
############################################################################################

locals {
  needs_infrastructure_iam_role  = var.volume_configuration != null || var.vpc_lattice_configurations != null
  create_infrastructure_iam_role = var.create && var.create_infrastructure_iam_role && local.needs_infrastructure_iam_role
  infrastructure_iam_role_arn    = local.needs_infrastructure_iam_role ? try(aws_iam_role.infrastructure_iam_role[0].arn, var.infrastructure_iam_role_arn) : null
  infrastructure_iam_role_name   = try(coalesce(var.infrastructure_iam_role_name, var.name), "")
}

data "aws_iam_policy_document" "infrastructure_iam_role" {
  count = local.create_infrastructure_iam_role ? 1 : 0

  statement {
    sid     = "ECSServiceAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "infrastructure_iam_role" {
  count = local.create_infrastructure_iam_role ? 1 : 0

  name        = var.infrastructure_iam_role_use_name_prefix ? null : local.infrastructure_iam_role_name
  name_prefix = var.infrastructure_iam_role_use_name_prefix ? "${local.infrastructure_iam_role_name}-" : null
  path        = var.infrastructure_iam_role_path
  description = coalesce(var.infrastructure_iam_role_description, "Amazon ECS infrastructure IAM role that is used to manage your infrastructure")

  assume_role_policy    = data.aws_iam_policy_document.infrastructure_iam_role[0].json
  permissions_boundary  = var.infrastructure_iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.infrastructure_iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "infrastructure_iam_role_ebs_policy" {
  count = local.create_infrastructure_iam_role && var.volume_configuration != null ? 1 : 0

  role       = aws_iam_role.infrastructure_iam_role[0].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForVolumes"
}

resource "aws_iam_role_policy_attachment" "infrastructure_iam_role_vpc_lattice_policy" {
  count = local.create_infrastructure_iam_role && var.vpc_lattice_configurations != null ? 1 : 0

  role       = aws_iam_role.infrastructure_iam_role[0].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForVpcLattice"
}
