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

variable "iam_role" {
  description = "ARN of the IAM role that allows Amazon ECS to make calls to your load balancer on your behalf"
  type        = string
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
