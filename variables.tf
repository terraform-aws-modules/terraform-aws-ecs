variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Cluster
################################################################################

variable "cluster_configuration" {
  description = "The execute command configuration for the cluster"
  type = object({
    execute_command_configuration = optional(object({
      kms_key_id = optional(string)
      log_configuration = optional(object({
        cloud_watch_encryption_enabled = optional(bool)
        cloud_watch_log_group_name     = optional(string)
        s3_bucket_encryption_enabled   = optional(bool)
        s3_bucket_name                 = optional(string)
        s3_kms_key_id                  = optional(string)
        s3_key_prefix                  = optional(string)
      }))
      logging = optional(string, "OVERRIDE")
    }))
    managed_storage_configuration = optional(object({
      fargate_ephemeral_storage_kms_key_id = optional(string)
      kms_key_id                           = optional(string)
    }))
  })
  default = {
    execute_command_configuration = {
      log_configuration = {
        cloud_watch_log_group_name = "placeholder" # will use CloudWatch log group created by module
      }
    }
  }
}

variable "cluster_name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

variable "cluster_service_connect_defaults" {
  description = "Configures a default Service Connect namespace"
  type = object({
    namespace = string
  })
  default = null
}

variable "cluster_setting" {
  description = "List of configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]
}
variable "cluster_tags" {
  description = "A map of additional tags to add to the cluster"
  type        = map(string)
  default     = {}
}

################################################################################
# CloudWatch Log Group
################################################################################

variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_name" {
  description = "Custom name of CloudWatch Log Group for ECS cluster"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 90
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_class" {
  description = "Specified the log class of the log group. Possible values are: `STANDARD` or `INFREQUENT_ACCESS`"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_tags" {
  description = "A map of additional tags to add to the log group created"
  type        = map(string)
  default     = {}
}

################################################################################
# Capacity Providers
################################################################################

variable "autoscaling_capacity_providers" {
  description = "Map of autoscaling capacity provider definitions to create for the cluster"
  type = map(object({
    auto_scaling_group_arn = string
    managed_draining       = optional(string, "ENABLED")
    managed_scaling = optional(object({
      instance_warmup_period    = optional(number)
      maximum_scaling_step_size = optional(number)
      minimum_scaling_step_size = optional(number)
      status                    = optional(string)
      target_capacity           = optional(number)
    }))
    managed_termination_protection = optional(string)
    name                           = optional(string) # Will fall back to use map key if not set
    tags                           = optional(map(string), {})
  }))
  default = null
}

variable "default_capacity_provider_strategy" {
  description = "Map of default capacity provider strategy definitions to use for the cluster"
  type = map(object({
    base   = optional(number)
    name   = optional(string) # Will fall back to use map key if not set
    weight = optional(number)
  }))
  default = null
}

################################################################################
# Task Execution - IAM Role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
################################################################################

variable "create_task_exec_iam_role" {
  description = "Determines whether the ECS task definition IAM role should be created"
  type        = bool
  default     = false
}

variable "task_exec_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "task_exec_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`task_exec_iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "task_exec_iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "task_exec_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "task_exec_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "task_exec_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

variable "task_exec_iam_role_policies" {
  description = "Map of IAM role policy ARNs to attach to the IAM role"
  type        = map(string)
  default     = {}
}

variable "create_task_exec_policy" {
  description = "Determines whether the ECS task definition IAM policy should be created. This includes permissions included in AmazonECSTaskExecutionRolePolicy as well as access to secrets and SSM parameters"
  type        = bool
  default     = true
}

variable "task_exec_ssm_param_arns" {
  description = "List of SSM parameter ARNs the task execution role will be permitted to get/read"
  type        = list(string)
  default     = []
}

variable "task_exec_secret_arns" {
  description = "List of SecretsManager secret ARNs the task execution role will be permitted to get/read"
  type        = list(string)
  default     = []
}

variable "task_exec_iam_statements" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type = map(object({
    sid           = optional(string)
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    effect        = optional(string, "Allow")
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))
  default = null
}

################################################################################
# Service(s)
################################################################################

variable "services" {
  description = "Map of service definitions to create"
  type = map(object({
    create         = optional(bool)
    create_service = optional(bool)
    tags           = optional(map(string))

    # Service
    ignore_task_definition_changes = optional(bool)
    alarms = optional(object({
      alarm_names = list(string)
      enable      = optional(bool)
      rollback    = optional(bool)
    }))
    availability_zone_rebalancing = optional(string)
    capacity_provider_strategy = optional(map(object({
      base              = optional(number)
      capacity_provider = string
      weight            = optional(number)
    })))
    deployment_circuit_breaker = optional(object({
      enable   = bool
      rollback = bool
    }))
    deployment_configuration = optional(object({
      strategy             = optional(string)
      bake_time_in_minutes = optional(string)
      lifecycle_hook = optional(map(object({
        hook_target_arn  = string
        role_arn         = string
        lifecycle_stages = list(string)
        hook_details     = optional(string)
      })))
    }))
    deployment_controller = optional(object({
      type = optional(string)
    }))
    deployment_maximum_percent         = optional(number, 200)
    deployment_minimum_healthy_percent = optional(number, 66)
    desired_count                      = optional(number, 1)
    enable_ecs_managed_tags            = optional(bool)
    enable_execute_command             = optional(bool)
    force_delete                       = optional(bool)
    force_new_deployment               = optional(bool)
    health_check_grace_period_seconds  = optional(number)
    launch_type                        = optional(string)
    load_balancer = optional(map(object({
      container_name   = string
      container_port   = number
      elb_name         = optional(string)
      target_group_arn = optional(string)
      advanced_configuration = optional(object({
        alternate_target_group_arn = string
        production_listener_rule   = string
        role_arn                   = string
        test_listener_rule         = optional(string)
      }))
    })))
    name               = optional(string) # Will fall back to use map key if not set
    assign_public_ip   = optional(bool)
    security_group_ids = optional(list(string))
    subnet_ids         = optional(list(string))
    ordered_placement_strategy = optional(map(object({
      field = optional(string)
      type  = string
    })))
    placement_constraints = optional(map(object({
      expression = optional(string)
      type       = string
    })))
    platform_version    = optional(string)
    propagate_tags      = optional(string)
    scheduling_strategy = optional(string)
    service_connect_configuration = optional(object({
      enabled = optional(bool)
      log_configuration = optional(object({
        log_driver = string
        options    = optional(map(string))
        secret_option = optional(list(object({
          name       = string
          value_from = string
        })))
      }))
      namespace = optional(string)
      service = optional(list(object({
        client_alias = optional(object({
          dns_name = optional(string)
          port     = number
          test_traffic_rules = optional(list(object({
            header = optional(object({
              name = string
              value = object({
                exact = string
              })
            }))
          })))
        }))
        discovery_name        = optional(string)
        ingress_port_override = optional(number)
        port_name             = string
        timeout = optional(object({
          idle_timeout_seconds        = optional(number)
          per_request_timeout_seconds = optional(number)
        }))
        tls = optional(object({
          issuer_cert_authority = object({
            aws_pca_authority_arn = string
          })
          kms_key  = optional(string)
          role_arn = optional(string)
        }))
      })))
    }))
    service_registries = optional(object({
      container_name = optional(string)
      container_port = optional(number)
      port           = optional(number)
      registry_arn   = string
    }))
    sigint_rollback = optional(bool)
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    triggers = optional(map(string))
    volume_configuration = optional(object({
      name = string
      managed_ebs_volume = object({
        encrypted        = optional(bool)
        file_system_type = optional(string)
        iops             = optional(number)
        kms_key_id       = optional(string)
        size_in_gb       = optional(number)
        snapshot_id      = optional(string)
        tag_specifications = optional(list(object({
          propagate_tags = optional(string)
          resource_type  = string
          tags           = optional(map(string))
        })))
        throughput  = optional(number)
        volume_type = optional(string)
      })
    }))
    vpc_lattice_configurations = optional(object({
      role_arn         = string
      target_group_arn = string
      port_name        = string
    }))
    wait_for_steady_state = optional(bool)
    service_tags          = optional(map(string))
    # Service - IAM Role
    create_iam_role               = optional(bool)
    iam_role_arn                  = optional(string)
    iam_role_name                 = optional(string)
    iam_role_use_name_prefix      = optional(bool)
    iam_role_path                 = optional(string)
    iam_role_description          = optional(string)
    iam_role_permissions_boundary = optional(string)
    iam_role_tags                 = optional(map(string))
    iam_role_statements = optional(list(object({
      sid           = optional(string)
      actions       = optional(list(string))
      not_actions   = optional(list(string))
      effect        = optional(string)
      resources     = optional(list(string))
      not_resources = optional(list(string))
      principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })))
      not_principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })))
      condition = optional(list(object({
        test     = string
        values   = list(string)
        variable = string
      })))
    })))
    # Task Definition
    create_task_definition = optional(bool)
    task_definition_arn    = optional(string)
    container_definitions = optional(map(object({
      operating_system_family = optional(string)
      tags                    = optional(map(string))

      # Container definition
      command = optional(list(string))
      cpu     = optional(number)
      dependsOn = optional(list(object({
        condition     = string
        containerName = string
      })))
      disableNetworking      = optional(bool)
      dnsSearchDomains       = optional(list(string))
      dnsServers             = optional(list(string))
      dockerLabels           = optional(map(string))
      dockerSecurityOptions  = optional(list(string))
      enable_execute_command = optional(bool)
      entrypoint             = optional(list(string))
      environment = optional(list(object({
        name  = string
        value = string
      })))
      environmentFiles = optional(list(object({
        type  = string
        value = string
      })))
      essential = optional(bool)
      extraHosts = optional(list(object({
        hostname  = string
        ipAddress = string
      })))
      firelensConfiguration = optional(object({
        options = optional(map(string))
        type    = optional(string)
      }))
      healthCheck = optional(object({
        command     = optional(list(string))
        interval    = optional(number)
        retries     = optional(number)
        startPeriod = optional(number)
        timeout     = optional(number)
      }))
      hostname    = optional(string)
      image       = optional(string)
      interactive = optional(bool)
      links       = optional(list(string))
      linuxParameters = optional(object({
        capabilities = optional(object({
          add  = optional(list(string))
          drop = optional(list(string))
        }))
        devices = optional(list(object({
          containerPath = optional(string)
          hostPath      = optional(string)
          permissions   = optional(list(string))
        })))
        initProcessEnabled = optional(bool)
        maxSwap            = optional(number)
        sharedMemorySize   = optional(number)
        swappiness         = optional(number)
        tmpfs = optional(list(object({
          containerPath = string
          mountOptions  = optional(list(string))
          size          = number
        })))
      }))
      logConfiguration = optional(object({
        logDriver = optional(string)
        options   = optional(map(string))
        secretOptions = optional(list(object({
          name      = string
          valueFrom = string
        })))
      }))
      memory            = optional(number)
      memoryReservation = optional(number)
      mountPoints = optional(list(object({
        containerPath = optional(string)
        readOnly      = optional(bool)
        sourceVolume  = optional(string)
      })), [])
      name = optional(string)
      portMappings = optional(list(object({
        appProtocol        = optional(string)
        containerPort      = optional(number)
        containerPortRange = optional(string)
        hostPort           = optional(number)
        name               = optional(string)
        protocol           = optional(string)
      })), [])
      privileged             = optional(bool)
      pseudoTerminal         = optional(bool)
      readonlyRootFilesystem = optional(bool)
      repositoryCredentials = optional(object({
        credentialsParameter = optional(string)
      }))
      resourceRequirements = optional(list(object({
        type  = string
        value = string
      })))
      restartPolicy = optional(object({
        enabled              = optional(bool)
        ignoredExitCodes     = optional(list(number))
        restartAttemptPeriod = optional(number)
      }))
      secrets = optional(list(object({
        name      = string
        valueFrom = string
      })))
      startTimeout = optional(number)
      stopTimeout  = optional(number)
      systemControls = optional(list(object({
        namespace = optional(string)
        value     = optional(string)
      })))
      ulimits = optional(list(object({
        hardLimit = number
        name      = string
        softLimit = number
      })))
      user               = optional(string)
      versionConsistency = optional(string)
      volumesFrom = optional(list(object({
        readOnly        = optional(bool)
        sourceContainer = optional(string)
      })))
      workingDirectory = optional(string)

      # Cloudwatch Log Group
      service                                = optional(string, "")
      enable_cloudwatch_logging              = optional(bool)
      create_cloudwatch_log_group            = optional(bool)
      cloudwatch_log_group_name              = optional(string)
      cloudwatch_log_group_use_name_prefix   = optional(bool)
      cloudwatch_log_group_class             = optional(string)
      cloudwatch_log_group_retention_in_days = optional(number)
      cloudwatch_log_group_kms_key_id        = optional(string)
    })))
    cpu                    = optional(number, 1024)
    enable_fault_injection = optional(bool)
    ephemeral_storage = optional(object({
      size_in_gib = number
    }))
    family       = optional(string)
    ipc_mode     = optional(string)
    memory       = optional(number, 2048)
    network_mode = optional(string)
    pid_mode     = optional(string)
    proxy_configuration = optional(object({
      container_name = string
      properties     = optional(map(string))
      type           = optional(string)
    }))
    requires_compatibilities = optional(list(string))
    runtime_platform = optional(object({
      cpu_architecture        = optional(string)
      operating_system_family = optional(string)
    }))
    skip_destroy = optional(bool)
    task_definition_placement_constraints = optional(map(object({
      expression = optional(string)
      type       = string
    })))
    track_latest = optional(bool)
    volume = optional(map(object({
      configure_at_launch = optional(bool)
      docker_volume_configuration = optional(object({
        autoprovision = optional(bool)
        driver        = optional(string)
        driver_opts   = optional(map(string))
        labels        = optional(map(string))
        scope         = optional(string)
      }))
      efs_volume_configuration = optional(object({
        authorization_config = optional(object({
          access_point_id = optional(string)
          iam             = optional(string)
        }))
        file_system_id          = string
        root_directory          = optional(string)
        transit_encryption      = optional(string)
        transit_encryption_port = optional(number)
      }))
      fsx_windows_file_server_volume_configuration = optional(object({
        authorization_config = optional(object({
          credentials_parameter = string
          domain                = string
        }))
        file_system_id = string
        root_directory = string
      }))
      host_path = optional(string)
      name      = optional(string)
    })))
    task_tags = optional(map(string))
    # Task Execution - IAM Role
    create_task_exec_iam_role               = optional(bool)
    task_exec_iam_role_arn                  = optional(string)
    task_exec_iam_role_name                 = optional(string)
    task_exec_iam_role_use_name_prefix      = optional(bool)
    task_exec_iam_role_path                 = optional(string)
    task_exec_iam_role_description          = optional(string)
    task_exec_iam_role_permissions_boundary = optional(string)
    task_exec_iam_role_tags                 = optional(map(string))
    task_exec_iam_role_policies             = optional(map(string))
    task_exec_iam_role_max_session_duration = optional(number)
    create_task_exec_policy                 = optional(bool)
    task_exec_ssm_param_arns                = optional(list(string))
    task_exec_secret_arns                   = optional(list(string))
    task_exec_iam_statements = optional(list(object({
      sid           = optional(string)
      actions       = optional(list(string))
      not_actions   = optional(list(string))
      effect        = optional(string)
      resources     = optional(list(string))
      not_resources = optional(list(string))
      principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })))
      not_principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })))
      condition = optional(list(object({
        test     = string
        values   = list(string)
        variable = string
      })))
    })))
    task_exec_iam_policy_path = optional(string)
    # Tasks - IAM Role
    create_tasks_iam_role               = optional(bool)
    tasks_iam_role_arn                  = optional(string)
    tasks_iam_role_name                 = optional(string)
    tasks_iam_role_use_name_prefix      = optional(bool)
    tasks_iam_role_path                 = optional(string)
    tasks_iam_role_description          = optional(string)
    tasks_iam_role_permissions_boundary = optional(string)
    tasks_iam_role_tags                 = optional(map(string))
    tasks_iam_role_policies             = optional(map(string))
    tasks_iam_role_statements = optional(list(object({
      sid           = optional(string)
      actions       = optional(list(string))
      not_actions   = optional(list(string))
      effect        = optional(string)
      resources     = optional(list(string))
      not_resources = optional(list(string))
      principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })))
      not_principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })))
      condition = optional(list(object({
        test     = string
        values   = list(string)
        variable = string
      })))
    })))
    # Task Set
    external_id = optional(string)
    scale = optional(object({
      unit  = optional(string)
      value = optional(number)
    }))
    wait_until_stable         = optional(bool)
    wait_until_stable_timeout = optional(string)
    # Autoscaling
    enable_autoscaling       = optional(bool)
    autoscaling_min_capacity = optional(number)
    autoscaling_max_capacity = optional(number)
    autoscaling_policies = optional(map(object({
      name        = optional(string) # Will fall back to the key name if not provided
      policy_type = optional(string)
      predictive_scaling_policy_configuration = optional(object({
        max_capacity_breach_behavior = optional(string)
        max_capacity_buffer          = optional(number)
        metric_specification = list(object({
          customized_capacity_metric_specification = optional(object({
            metric_data_query = list(object({
              expression = optional(string)
              id         = string
              label      = optional(string)
              metric_stat = optional(object({
                metric = object({
                  dimension = optional(list(object({
                    name  = string
                    value = string
                  })))
                  metric_name = optional(string)
                  namespace   = optional(string)
                })
                stat = string
                unit = optional(string)
              }))
              return_data = optional(bool)
            }))
          }))
          customized_load_metric_specification = optional(object({
            metric_data_query = list(object({
              expression = optional(string)
              id         = string
              label      = optional(string)
              metric_stat = optional(object({
                metric = object({
                  dimension = optional(list(object({
                    name  = string
                    value = string
                  })))
                  metric_name = optional(string)
                  namespace   = optional(string)
                })
                stat = string
                unit = optional(string)
              }))
              return_data = optional(bool)
            }))
          }))
          customized_scaling_metric_specification = optional(object({
            metric_data_query = list(object({
              expression = optional(string)
              id         = string
              label      = optional(string)
              metric_stat = optional(object({
                metric = object({
                  dimension = optional(list(object({
                    name  = string
                    value = string
                  })))
                  metric_name = optional(string)
                  namespace   = optional(string)
                })
                stat = string
                unit = optional(string)
              }))
              return_data = optional(bool)
            }))
          }))
          predefined_load_metric_specification = optional(object({
            predefined_metric_type = string
            resource_label         = optional(string)
          }))
          predefined_metric_pair_specification = optional(object({
            predefined_metric_type = string
            resource_label         = optional(string)
          }))
          predefined_scaling_metric_specification = optional(object({
            predefined_metric_type = string
            resource_label         = optional(string)
          }))
          target_value = number
        }))
        mode                   = optional(string)
        scheduling_buffer_time = optional(number)
      }))
      step_scaling_policy_configuration = optional(object({
        adjustment_type          = optional(string)
        cooldown                 = optional(number)
        metric_aggregation_type  = optional(string)
        min_adjustment_magnitude = optional(number)
        step_adjustment = optional(list(object({
          metric_interval_lower_bound = optional(string)
          metric_interval_upper_bound = optional(string)
          scaling_adjustment          = number
        })))
      }))
      target_tracking_scaling_policy_configuration = optional(object({
        customized_metric_specification = optional(object({
          dimensions = optional(list(object({
            name  = string
            value = string
          })))
          metric_name = optional(string)
          metrics = optional(list(object({
            expression = optional(string)
            id         = string
            label      = optional(string)
            metric_stat = optional(object({
              metric = object({
                dimensions = optional(list(object({
                  name  = string
                  value = string
                })))
                metric_name = string
                namespace   = string
              })
              stat = string
              unit = optional(string)
            }))
            return_data = optional(bool)
          })))
          namespace = optional(string)
          statistic = optional(string)
          unit      = optional(string)
        }))

        disable_scale_in = optional(bool)
        predefined_metric_specification = optional(object({
          predefined_metric_type = string
          resource_label         = optional(string)
        }))
        scale_in_cooldown  = optional(number)
        scale_out_cooldown = optional(number)
        target_value       = optional(number)
      }))
    })))
    autoscaling_scheduled_actions = optional(map(object({
      name         = optional(string)
      min_capacity = number
      max_capacity = number
      schedule     = string
      start_time   = optional(string)
      end_time     = optional(string)
      timezone     = optional(string)
    })))
    # Security Group
    create_security_group          = optional(bool)
    vpc_id                         = optional(string)
    security_group_name            = optional(string)
    security_group_use_name_prefix = optional(bool)
    security_group_description     = optional(string)
    security_group_ingress_rules = optional(map(object({
      cidr_ipv4                    = optional(string)
      cidr_ipv6                    = optional(string)
      description                  = optional(string)
      from_port                    = optional(string)
      ip_protocol                  = optional(string)
      prefix_list_id               = optional(string)
      referenced_security_group_id = optional(string)
      tags                         = optional(map(string))
      to_port                      = optional(string)
    })))
    security_group_egress_rules = optional(map(object({
      cidr_ipv4                    = optional(string)
      cidr_ipv6                    = optional(string)
      description                  = optional(string)
      from_port                    = optional(string)
      ip_protocol                  = optional(string)
      prefix_list_id               = optional(string)
      referenced_security_group_id = optional(string)
      tags                         = optional(map(string))
      to_port                      = optional(string)
    })))
    security_group_tags = optional(map(string))
    # ECS Infrastructure IAM Role
    create_infrastructure_iam_role               = optional(bool)
    infrastructure_iam_role_arn                  = optional(string)
    infrastructure_iam_role_name                 = optional(string)
    infrastructure_iam_role_use_name_prefix      = optional(bool)
    infrastructure_iam_role_path                 = optional(string)
    infrastructure_iam_role_description          = optional(string)
    infrastructure_iam_role_permissions_boundary = optional(string)
    infrastructure_iam_role_tags                 = optional(map(string))
  }))
  default = null
}
