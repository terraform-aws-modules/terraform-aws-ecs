variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "create_service" {
  description = "Determines whether service resource will be created (set to `false` in case you want to create task definition only)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Service
################################################################################

variable "ignore_task_definition_changes" {
  description = "Whether changes to service `task_definition` changes should be ignored"
  type        = bool
  default     = false
}

variable "alarms" {
  description = "Information about the CloudWatch alarms"
  type = object({
    alarm_names = list(string)
    enable      = optional(bool, true)
    rollback    = optional(bool, true)
  })
  default = null
}

variable "availability_zone_rebalancing" {
  description = " ECS automatically redistributes tasks within a service across Availability Zones (AZs) to mitigate the risk of impaired application availability due to underlying infrastructure failures and task lifecycle activities. The valid values are `ENABLED` and `DISABLED`. Defaults to `DISABLED`"
  type        = string
  default     = null
}

variable "capacity_provider_strategy" {
  description = "Capacity provider strategies to use for the service. Can be one or more"
  type = map(object({
    base              = optional(number)
    capacity_provider = string
    weight            = optional(number)
  }))
  default = null
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster where the resources will be provisioned"
  type        = string
  default     = ""
}

variable "deployment_circuit_breaker" {
  description = "Configuration block for deployment circuit breaker"
  type = object({
    enable   = bool
    rollback = bool
  })
  default = null
}

variable "deployment_controller" {
  description = "Configuration block for deployment controller configuration"
  type = object({
    type = optional(string)
  })
  default = null
}

variable "deployment_maximum_percent" {
  description = "Upper limit (as a percentage of the service's `desired_count`) of the number of running tasks that can be running in a service during a deployment"
  type        = number
  default     = null
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit (as a percentage of the service's `desired_count`) of the number of running tasks that must remain running and healthy in a service during a deployment"
  type        = number
  default     = null
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}

variable "enable_ecs_managed_tags" {
  description = "Specifies whether to enable Amazon ECS managed tags for the tasks within the service"
  type        = bool
  default     = true
}

variable "enable_execute_command" {
  description = "Specifies whether to enable Amazon ECS Exec for the tasks within the service"
  type        = bool
  default     = false
}

variable "force_delete" {
  description = "Enable to delete a service even if it wasn't scaled down to zero tasks. It's only necessary to use this if the service uses the `REPLICA` scheduling strategy"
  type        = bool
  default     = null
}

variable "force_new_deployment" {
  description = "Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination, roll Fargate tasks onto a newer platform version, or immediately deploy `ordered_placement_strategy` and `placement_constraints` updates"
  type        = bool
  default     = true
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers"
  type        = number
  default     = null
}

variable "launch_type" {
  description = "Launch type on which to run your service. The valid values are `EC2`, `FARGATE`, and `EXTERNAL`. Defaults to `FARGATE`"
  type        = string
  default     = "FARGATE"
}

variable "load_balancer" {
  description = "Configuration block for load balancers"
  type = map(object({
    container_name   = string
    container_port   = number
    elb_name         = optional(string)
    target_group_arn = optional(string)
  }))
  default = null
}

variable "name" {
  description = "Name of the service (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = null
}

variable "assign_public_ip" {
  description = "Assign a public IP address to the ENI (Fargate launch type only)"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "List of security groups to associate with the task or service"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnets to associate with the task or service"
  type        = list(string)
  default     = []
}

variable "ordered_placement_strategy" {
  description = "Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence"
  type = map(object({
    field = optional(string)
    type  = string
  }))
  default = null
}

variable "placement_constraints" {
  description = "Configuration block for rules that are taken into consideration during task placement (up to max of 10). This is set at the service, see `task_definition_placement_constraints` for setting at the task definition"
  type = map(object({
    expression = optional(string)
    type       = string
  }))
  default = null
}

variable "platform_version" {
  description = "Platform version on which to run your service. Only applicable for `launch_type` set to `FARGATE`. Defaults to `LATEST`"
  type        = string
  default     = null
}

variable "propagate_tags" {
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are `SERVICE` and `TASK_DEFINITION`"
  type        = string
  default     = null
}

variable "scheduling_strategy" {
  description = "Scheduling strategy to use for the service. The valid values are `REPLICA` and `DAEMON`. Defaults to `REPLICA`"
  type        = string
  default     = null
}

variable "service_connect_configuration" {
  description = "The ECS Service Connect configuration for this service to discover and connect to services, and be discovered by, and connected from, other services within a namespace"
  type = object({
    enabled = optional(bool, true)
    log_configuration = optional(object({
      log_driver = string
      options    = optional(map(string))
      secret_option = optional(object({
        name       = string
        value_from = string
      }))
    }))
    namespace = optional(string)
    service = optional(list(object({
      client_alias = optional(object({
        dns_name = optional(string)
        port     = number
      }))
      discovery_name        = optional(string)
      ingress_port_override = optional(number)
      port_name             = string
      timeout = optional(object({
        idle_timeout_seconds        = optional(number)
        per_request_timeout_seconds = optional(number)
      }))
      tls = optional(object({
        issuer_cert_authority = optional(object({
          aws_pca_authority_arn = string
        }))
        kms_key  = optional(string)
        role_arn = optional(string)
      }))
    })))
  })
  default = null
}

variable "service_registries" {
  description = "Service discovery registries for the service"
  type = object({
    container_name = optional(string)
    container_port = optional(number)
    port           = optional(number)
    registry_arn   = string
  })
  default = null
}

variable "timeouts" {
  description = "Create, update, and delete timeout configurations for the service"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "triggers" {
  description = "Map of arbitrary keys and values that, when changed, will trigger an in-place update (redeployment). Useful with `timestamp()`"
  type        = map(string)
  default     = null
}

variable "wait_for_steady_state" {
  description = "If true, Terraform will wait for the service to reach a steady state before continuing. Default is `false`"
  type        = bool
  default     = null
}

variable "volume_configuration" {
  description = "Configuration for a volume specified in the task definition as a volume that is configured at launch time"
  type = object({
    name = string
    managed_ebs_volume = list(object({
      encrypted        = optional(bool)
      file_system_type = optional(string)
      iops             = optional(number)
      kms_key_id       = optional(string)
      size_in_gb       = optional(number)
      snapshot_id      = optional(string)
      throughput       = optional(number)
      volume_type      = optional(string)
      tag_specifications = optional(list(object({
        resource_type  = string
        propagate_tags = optional(string, "TASK_DEFINITION")
        tags           = optional(map(string))
      })))
    }))
  })
  default = null
}

variable "vpc_lattice_configurations" {
  description = "The VPC Lattice configuration for your service that allows Lattice to connect, secure, and monitor your service across multiple accounts and VPCs"
  type = object({
    role_arn         = string
    target_group_arn = string
    port_name        = string
  })
  default = null
}

variable "service_tags" {
  description = "A map of additional tags to add to the service"
  type        = map(string)
  default     = {}
}

################################################################################
# Service - IAM Role
################################################################################

variable "create_iam_role" {
  description = "Determines whether the ECS service IAM role should be created"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

variable "iam_role_statements" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type = list(object({
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
  }))
  default = null
}

################################################################################
# Task Definition
################################################################################

variable "create_task_definition" {
  description = "Determines whether to create a task definition or use existing/provided"
  type        = bool
  default     = true
}

variable "task_definition_arn" {
  description = "Existing task definition ARN. Required when `create_task_definition` is `false`"
  type        = string
  default     = null
}

variable "container_definitions" {
  description = "A map of valid [container definitions](http://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html). Please note that you should only provide values that are part of the container definition document"
  type        = any
  default     = {}
}

variable "container_definition_defaults" {
  description = "A map of default values for [container definitions](http://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html) created by `container_definitions`"
  type        = any
  default     = {}
}

variable "cpu" {
  description = "Number of cpu units used by the task. If the `requires_compatibilities` is `FARGATE` this field is required"
  type        = number
  default     = 1024
}

variable "ephemeral_storage" {
  description = "The amount of ephemeral storage to allocate for the task. This parameter is used to expand the total amount of ephemeral storage available, beyond the default amount, for tasks hosted on AWS Fargate"
  type = object({
    size_in_gib = number
  })
  default = null
}

variable "family" {
  description = "A unique name for your task definition"
  type        = string
  default     = null
}

variable "inference_accelerator" {
  description = "Configuration block(s) with Inference Accelerators settings"
  type = object({
    device_name = string
    device_type = string
  })
  default = null
}

variable "ipc_mode" {
  description = "IPC resource namespace to be used for the containers in the task The valid values are `host`, `task`, and `none`"
  type        = string
  default     = null
}

variable "memory" {
  description = "Amount (in MiB) of memory used by the task. If the `requires_compatibilities` is `FARGATE` this field is required"
  type        = number
  default     = 2048
}

variable "network_mode" {
  description = "Docker networking mode to use for the containers in the task. Valid values are `none`, `bridge`, `awsvpc`, and `host`"
  type        = string
  default     = "awsvpc"
}

variable "pid_mode" {
  description = "Process namespace to use for the containers in the task. The valid values are `host` and `task`"
  type        = string
  default     = null
}

variable "task_definition_placement_constraints" {
  description = "Configuration block for rules that are taken into consideration during task placement (up to max of 10). This is set at the task definition, see `placement_constraints` for setting at the service"
  type = map(object({
    expression = optional(string)
    type       = string
  }))
  default = null
}

variable "proxy_configuration" {
  description = "Configuration block for the App Mesh proxy"
  type = object({
    container_name = string
    properties     = optional(map(string))
    type           = optional(string)
  })
  default = null
}

variable "requires_compatibilities" {
  description = "Set of launch types required by the task. The valid values are `EC2` and `FARGATE`"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "runtime_platform" {
  description = "Configuration block for `runtime_platform` that containers in your task may use"
  type = object({
    cpu_architecture        = optional(string, "X86_64")
    operating_system_family = optional(string, "LINUX")
  })
  default = {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

variable "track_latest" {
  description = "Whether should track latest `ACTIVE` task definition on AWS or the one created with the resource stored in state. Default is `false`. Useful in the event the task definition is modified outside of this resource"
  type        = bool
  default     = true
}

variable "skip_destroy" {
  description = "If true, the task is not deleted when the service is deleted"
  type        = bool
  default     = null
}

variable "volume" {
  description = "Configuration block for volumes that containers in your task may use"
  type = map(object({
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
  }))
  default = null
}

variable "task_tags" {
  description = "A map of additional tags to add to the task definition/set created"
  type        = map(string)
  default     = {}
}

################################################################################
# Task Execution - IAM Role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
################################################################################

variable "create_task_exec_iam_role" {
  description = "Determines whether the ECS task definition IAM role should be created"
  type        = bool
  default     = true
}

variable "task_exec_iam_role_arn" {
  description = "Existing IAM role ARN"
  type        = string
  default     = null
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

variable "task_exec_iam_role_max_session_duration" {
  description = "Maximum session duration (in seconds) for ECS task execution role. Default is 3600."
  type        = number
  default     = null
}

variable "create_task_exec_policy" {
  description = "Determines whether the ECS task definition IAM policy should be created. This includes permissions included in AmazonECSTaskExecutionRolePolicy as well as access to secrets and SSM parameters"
  type        = bool
  default     = true
}

variable "task_exec_ssm_param_arns" {
  description = "List of SSM parameter ARNs the task execution role will be permitted to get/read"
  type        = list(string)
  default     = ["arn:aws:ssm:*:*:parameter/*"]
}

variable "task_exec_secret_arns" {
  description = "List of SecretsManager secret ARNs the task execution role will be permitted to get/read"
  type        = list(string)
  default     = ["arn:aws:secretsmanager:*:*:secret:*"]
}

variable "task_exec_iam_statements" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type = list(object({
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
  }))
  default = null
}

################################################################################
# Tasks - IAM role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html
################################################################################

variable "create_tasks_iam_role" {
  description = "Determines whether the ECS tasks IAM role should be created"
  type        = bool
  default     = true
}

variable "tasks_iam_role_arn" {
  description = "Existing IAM role ARN"
  type        = string
  default     = null
}

variable "tasks_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "tasks_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`tasks_iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "tasks_iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "tasks_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "tasks_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "tasks_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

variable "tasks_iam_role_policies" {
  description = "Map of IAM role policy ARNs to attach to the IAM role"
  type        = map(string)
  default     = {}
}

variable "tasks_iam_role_statements" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type = list(object({
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
    conditions = optional(list(object({
      test     = string
      values   = list(string)
      variable = string
    })))
  }))
  default = null
}

################################################################################
# Task Set
################################################################################

variable "external_id" {
  description = "The external ID associated with the task set"
  type        = string
  default     = null
}

variable "scale" {
  description = "A floating-point percentage of the desired number of tasks to place and keep running in the task set"
  type = object({
    unit  = optional(string)
    value = optional(number)
  })
  default = null
}

variable "wait_until_stable" {
  description = "Whether terraform should wait until the task set has reached `STEADY_STATE`"
  type        = bool
  default     = null
}

variable "wait_until_stable_timeout" {
  description = "Wait timeout for task set to reach `STEADY_STATE`. Valid time units include `ns`, `us` (or µs), `ms`, `s`, `m`, and `h`. Default `10m`"
  type        = string
  default     = null
}

################################################################################
# Autoscaling
################################################################################

variable "enable_autoscaling" {
  description = "Determines whether to enable autoscaling for the service"
  type        = bool
  default     = true
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks to run in your service"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks to run in your service"
  type        = number
  default     = 10
}

variable "autoscaling_policies" {
  description = "Map of autoscaling policies to create for the service"
  type        = any
  default = {
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
  }
}

variable "autoscaling_scheduled_actions" {
  description = "Map of autoscaling scheduled actions to create for the service"
  type = map(object({
    name         = optional(string)
    min_capacity = number
    max_capacity = number
    schedule     = string
    start_time   = optional(string)
    end_time     = optional(string)
    timezone     = optional(string)
  }))
  default = null
}

################################################################################
# Security Group
################################################################################

variable "create_security_group" {
  description = "Determines if a security group is created"
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Name to use on security group created"
  type        = string
  default     = null
}

variable "security_group_use_name_prefix" {
  description = "Determines whether the security group name (`security_group_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = null
}

variable "security_group_ingress_rules" {
  description = "Security group ingress rules to add to the security group created"
  type = map(object({
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(string)
    ip_protocol                  = optional(string)
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
    to_port                      = optional(string)
  }))
  default = null
}

variable "security_group_egress_rules" {
  description = "Security group egress rules to add to the security group created"
  type = map(object({
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(string)
    ip_protocol                  = optional(string)
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
    to_port                      = optional(string)
  }))
  default = null
}

variable "security_group_tags" {
  description = "A map of additional tags to add to the security group created"
  type        = map(string)
  default     = {}
}

############################################################################################
# ECS infrastructure IAM role
############################################################################################

variable "create_infrastructure_iam_role" {
  description = "Determines whether the ECS infrastructure IAM role should be created"
  type        = bool
  default     = true
}

variable "infrastructure_iam_role_arn" {
  description = "Existing IAM role ARN"
  type        = string
  default     = null
}

variable "infrastructure_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "infrastructure_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "infrastructure_iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "infrastructure_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "infrastructure_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "infrastructure_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}
