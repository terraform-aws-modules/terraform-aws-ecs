variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
  nullable    = false
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
  nullable    = false
}

################################################################################
# Express Service
################################################################################

variable "cluster" {
  description = "Name or ARN of the ECS cluster. Defaults to `default`"
  type        = string
  default     = null
}

variable "cpu" {
  description = "Number of CPU units used by the task. Valid values are powers of `2` between `256` and `4096`"
  type        = string
  default     = null
}

variable "health_check_path" {
  description = "Path for health check requests. Defaults to `/ping`"
  type        = string
  default     = null
}

variable "memory" {
  description = "Amount of memory (in MiB) used by the task. Valid values are between `512` and `8192`"
  type        = string
  default     = null
}

variable "name" {
  description = "Name of the service. If not specified, a name will be generated. Changing this forces a new resource to be created"
  type        = string
  default     = ""
}

variable "network_configuration" {
  description = "The network configuration for task in this service revision"
  type = object({
    security_groups = optional(list(string), [])
    subnets         = optional(list(string))
  })
  default = null
}

variable "primary_container" {
  description = "The primary container configuration for this service revision"
  type = object({
    aws_logs_configuration = optional(object({
      log_group         = string
      log_stream_prefix = string
    }))
    command        = optional(list(string))
    container_port = optional(number)
    environment = optional(list(object({
      name  = string
      value = string
    })))
    image = string
    repository_credentials = optional(object({
      credentials_parameter = string
    }))
    secret = optional(list(object({
      name       = string
      value_from = string
    })))
  })
  default = null
}

variable "scaling_target" {
  description = "The auto-scaling configuration for this service revision"
  type = object({
    auto_scaling_metric       = string
    auto_scaling_target_value = number
    max_task_count            = number
    min_task_count            = number
  })
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
  default  = {}
  nullable = false
}

variable "security_group_tags" {
  description = "A map of additional tags to add to the security group created"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
  default     = null
}

################################################################################
# Execution IAM Role
################################################################################

variable "create_execution_iam_role" {
  description = "Determines whether the ECS task definition IAM role should be created"
  type        = bool
  default     = true
  nullable    = false
}

variable "execution_iam_role_arn" {
  description = "Existing IAM role ARN"
  type        = string
  default     = null
}

variable "execution_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "execution_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`execution_iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "execution_iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "execution_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "execution_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "execution_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "execution_iam_role_policies" {
  description = "Map of IAM role policy ARNs to attach to the IAM role"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "execution_iam_role_max_session_duration" {
  description = "Maximum session duration (in seconds) for ECS task execution role. Default is 3600."
  type        = number
  default     = null
}

variable "create_execution_policy" {
  description = "Determines whether the ECS task definition IAM policy should be created. This includes permissions included in AmazonECSTaskExecutionRolePolicy as well as access to secrets and SSM parameters"
  type        = bool
  default     = true
  nullable    = false
}

variable "execution_ssm_param_arns" {
  description = "List of SSM parameter ARNs the task execution role will be permitted to get/read"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "execution_secret_arns" {
  description = "List of SecretsManager secret ARNs the task execution role will be permitted to get/read"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "execution_iam_statements" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type = map(object({
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

variable "execution_iam_policy_path" {
  description = "Path for the iam role"
  type        = string
  default     = null
}

############################################################################################
# Infrastructure IAM Role
############################################################################################

variable "create_infrastructure_iam_role" {
  description = "Determines whether the ECS infrastructure IAM role should be created"
  type        = bool
  default     = true
  nullable    = false
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
# Task IAM Role
################################################################################

variable "create_task_iam_role" {
  description = "Determines whether the ECS task IAM role should be created"
  type        = bool
  default     = true
  nullable    = false
}

variable "task_iam_role_arn" {
  description = "Existing IAM role ARN"
  type        = string
  default     = null
}

variable "task_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "task_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`task_iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "task_iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "task_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "task_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "task_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "task_iam_role_policies" {
  description = "Map of additioanl IAM role policy ARNs to attach to the IAM role"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "task_iam_role_statements" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type = map(object({
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

variable "task_iam_role_max_session_duration" {
  description = "Maximum session duration (in seconds) for ECS task role. Default is 3600."
  type        = number
  default     = null
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
  default     = 14
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
