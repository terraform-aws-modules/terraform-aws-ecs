variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
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

variable "ignore_desired_count_changes" {
  description = "Whether changes to service `desired_count` changes should be ignored. Used for autoscaling of tasks; will replace entire service when changed"
  type        = bool
  default     = true
}

variable "capacity_provider_strategy" {
  description = "Capacity provider strategies to use for the service. Can be one or more"
  type        = any
  default     = {}
}

variable "cluster" {
  description = "ARN of an ECS cluster"
  type        = string
  default     = ""
}

variable "deployment_circuit_breaker" {
  description = "Configuration block for deployment circuit breaker"
  type        = any
  default     = {}
}

variable "deployment_controller" {
  description = "Configuration block for deployment controller configuration"
  type        = any
  default     = {}
}

variable "deployment_maximum_percent" {
  description = "Upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment"
  type        = number
  default     = null
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment"
  type        = number
  default     = null
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running. Defaults to `0`"
  type        = number
  default     = null
}

variable "enable_ecs_managed_tags" {
  description = "Specifies whether to enable Amazon ECS managed tags for the tasks within the service"
  type        = bool
  default     = null
}

variable "enable_execute_command" {
  description = "Specifies whether to enable Amazon ECS Exec for the tasks within the service"
  type        = bool
  default     = null
}

variable "force_new_deployment" {
  description = "Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination, roll Fargate tasks onto a newer platform version, or immediately deploy `ordered_placement_strategy` and `placement_constraints` updates"
  type        = bool
  default     = null
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers"
  type        = number
  default     = null
}

variable "launch_type" {
  description = "Launch type on which to run your service. The valid values are `EC2`, `FARGATE`, and `EXTERNAL`. Defaults to `EC2`"
  type        = string
  default     = null
}

variable "load_balancer" {
  description = "Configuration block for load balancers"
  type        = any
  default     = {}
}

variable "name" {
  description = "Name of the service (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = null
}

variable "network_configuration" {
  description = "Network configuration for the service. This parameter is required for task definitions that use the awsvpc network mode to receive their own Elastic Network Interface, and it is not supported for other network modes"
  type        = any
  default     = {}
}

variable "ordered_placement_strategy" {
  description = "Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence"
  type        = any
  default     = {}
}

variable "placement_constraints" {
  description = "Rules that are taken into consideration during task placement"
  type        = any
  default     = {}
}

variable "platform_version" {
  description = "Platform version on which to run your service. Only applicable for `launch_type` set to `FARGATE`. Defaults to `LATEST`"
  type        = string
  default     = null
}

variable "propagate_tags" {
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are `SERVICE` and `TASK_DEFINITION`"
  type        = bool
  default     = null
}

variable "scheduling_strategy" {
  description = "Scheduling strategy to use for the service. The valid values are `REPLICA` and `DAEMON`. Defaults to `REPLICA`"
  type        = string
  default     = null
}

variable "service_registries" {
  description = "Service discovery registries for the service"
  type        = any
  default     = {}
}

variable "task_definition" {
  description = "Family and revision (`family:revision`) or full ARN of the task definition that you want to run in your service. Required unless using the `EXTERNAL` deployment controller"
  type        = string
  default     = null
}

variable "wait_for_steady_state" {
  description = "If true, Terraform will wait for the service to reach a steady state before continuing. Default is `false`"
  type        = bool
  default     = null
}

################################################################################
# Service - IAM Role
################################################################################

variable "create_iam_role" {
  description = "Determines whether the ECS service IAM role should be created"
  type        = bool
  default     = false
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

################################################################################
# Task Definition
################################################################################

variable "create_task_def" {
  description = "Determines whether to create a task definition or use existing/provided"
  type        = bool
  default     = true
}

variable "task_def_container_definitions" {
  description = "A list of valid [container definitions](http://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html) provided as a single valid JSON document. Please note that you should only provide values that are part of the container definition document"
  type        = string
  default     = ""
}

variable "task_def_cpu" {
  description = "Number of cpu units used by the task. If the `task_requires_compatibilities` is `FARGATE` this field is required"
  type        = number
  default     = null
}

variable "task_def_ephemeral_storage" {
  description = "The amount of ephemeral storage to allocate for the task. This parameter is used to expand the total amount of ephemeral storage available, beyond the default amount, for tasks hosted on AWS Fargate"
  type        = any
  default     = {}
}

variable "task_def_family" {
  description = "A unique name for your task definition"
  type        = string
  default     = null
}

variable "task_def_inference_accelerator" {
  description = "Configuration block(s) with Inference Accelerators settings"
  type        = any
  default     = {}
}

variable "task_def_ipc_mode" {
  description = "IPC resource namespace to be used for the containers in the task The valid values are `host`, `task`, and `none`"
  type        = string
  default     = null
}

variable "task_def_memory" {
  description = "Amount (in MiB) of memory used by the task. If the `task_requires_compatibilities` is `FARGATE` this field is required"
  type        = number
  default     = null
}

variable "task_def_network_mode" {
  description = "Docker networking mode to use for the containers in the task. Valid values are `none`, `bridge`, `awsvpc`, and `host`"
  type        = string
  default     = null
}

variable "task_def_pid_mode" {
  description = "Process namespace to use for the containers in the task. The valid values are `host` and `task`"
  type        = string
  default     = null
}

variable "task_def_placement_constraints" {
  description = "Configuration block for rules that are taken into consideration during task placement (up to max of 10)"
  type        = any
  default     = {}
}

variable "task_def_proxy_configuration" {
  description = "Configuration block for the App Mesh proxy"
  type        = any
  default     = {}
}

variable "task_def_requires_compatibilities" {
  description = "Set of launch types required by the task. The valid values are `EC2` and `FARGATE`"
  type        = list(string)
  default     = []
}

variable "task_def_runtime_platform" {
  description = "Configuration block for `task_runtime_platform` that containers in your task may use"
  type        = any
  default     = {}
}

variable "task_def_skip_destroy" {
  description = "If true, the task is not deleted when the service is deleted"
  type        = bool
  default     = null
}

variable "task_def_volume" {
  description = "Configuration block for volumes that containers in your task may use"
  type        = any
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
