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

variable "disable_v7_default_name_description" {
  description = "[DEPRECATED - will be removed in v8.0] Determines whether to disable the default postfix added to resource names and descriptions added in v7.0"
  type        = bool
  default     = false
}

################################################################################
# Cluster
################################################################################

variable "configuration" {
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

variable "name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

variable "service_connect_defaults" {
  description = "Configures a default Service Connect namespace"
  type = object({
    namespace = string
  })
  default = null
}

variable "setting" {
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

variable "cluster_capacity_providers_wait_duration" {
  description = "Duration to wait after the ECS cluster has become active before attaching the cluster capacity providers"
  type        = string
  default     = "20s"
}

variable "cluster_capacity_providers" {
  description = "List of capacity provider names to associate with the ECS cluster. Note: any capacity providers created by this module will be automatically added"
  type        = list(string)
  default     = []
}

variable "capacity_providers" {
  description = "Map of capacity provider definitions to create"
  type = map(object({
    auto_scaling_group_provider = optional(object({
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
    }))
    managed_instances_provider = optional(object({
      infrastructure_role_arn = optional(string)
      instance_launch_template = object({
        capacity_option_type     = optional(string)
        ec2_instance_profile_arn = optional(string)
        instance_requirements = optional(object({
          accelerator_count = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          accelerator_manufacturers = optional(list(string))
          accelerator_names         = optional(list(string))
          accelerator_total_memory_mib = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          accelerator_types      = optional(list(string))
          allowed_instance_types = optional(list(string))
          bare_metal             = optional(string)
          baseline_ebs_bandwidth_mbps = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          burstable_performance                                   = optional(string)
          cpu_manufacturers                                       = optional(list(string))
          excluded_instance_types                                 = optional(list(string))
          instance_generations                                    = optional(list(string))
          local_storage                                           = optional(string)
          local_storage_types                                     = optional(list(string))
          max_spot_price_as_percentage_of_optimal_on_demand_price = optional(number)
          memory_gib_per_vcpu = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          memory_mib = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          network_bandwidth_gbps = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          network_interface_count = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          on_demand_max_price_percentage_over_lowest_price = optional(number)
          require_hibernate_support                        = optional(bool)
          spot_max_price_percentage_over_lowest_price      = optional(number)
          total_local_storage_gb = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          vcpu_count = optional(object({
            max = optional(number)
            min = optional(number)
          }))
        }))
        monitoring = optional(string)
        network_configuration = optional(object({
          security_groups = optional(list(string), [])
          subnets         = list(string)
        }))
        storage_configuration = optional(object({
          storage_size_gib = number
        }))
      })
      propagate_tags = optional(string, "CAPACITY_PROVIDER")
    }))
    name = optional(string) # Will fall back to use map key if not set
    tags = optional(map(string), {})
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
  default  = {}
  nullable = false
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

############################################################################################
# Infrastructure IAM role
############################################################################################

variable "create_infrastructure_iam_role" {
  description = "Determines whether the ECS infrastructure IAM role should be created"
  type        = bool
  default     = true
  nullable    = false
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
  nullable    = false
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
  nullable    = false
}

################################################################################
# Infrastructure IAM role policy
################################################################################

variable "infrastructure_iam_role_source_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s"
  type        = list(string)
  default     = []
}

variable "infrastructure_iam_role_override_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid`"
  type        = list(string)
  default     = []
}

variable "infrastructure_iam_role_statements" {
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
# Node IAM role & instance profile
################################################################################

variable "create_node_iam_instance_profile" {
  description = "Determines whether an IAM instance profile is created or to use an existing IAM instance profile"
  type        = bool
  default     = true
  nullable    = false
}

variable "node_iam_role_name" {
  description = "Name to use on IAM role/instance profile created"
  type        = string
  default     = null
}

variable "node_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role/instance profile name (`node_iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "node_iam_role_path" {
  description = "IAM role/instance profile path"
  type        = string
  default     = null
}

variable "node_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = "ECS Managed Instances node IAM role"
  nullable    = false
}

variable "node_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "node_iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "node_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role/instance profile created"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# Node IAM role policy
################################################################################

variable "node_iam_role_source_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s"
  type        = list(string)
  default     = []
}

variable "node_iam_role_override_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid`"
  type        = list(string)
  default     = []
}

variable "node_iam_role_statements" {
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
# Security Group
################################################################################

variable "create_security_group" {
  description = "Determines if a security group is created"
  type        = bool
  default     = true
  nullable    = false
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
  default     = null
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
  nullable    = false
}

variable "security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = null
}

variable "security_group_ingress_rules" {
  description = "Security group ingress rules to add to the security group created"
  type = map(object({
    name = optional(string)

    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(string)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
    to_port                      = optional(string)
  }))
  default  = {}
  nullable = false
}

variable "security_group_egress_rules" {
  description = "Security group egress rules to add to the security group created"
  type = map(object({
    name = optional(string)

    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(string)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
    to_port                      = optional(string)
  }))
  default = {
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
  }
  nullable = false
}

variable "security_group_tags" {
  description = "A map of additional tags to add to the security group created"
  type        = map(string)
  default     = {}
  nullable    = false
}
