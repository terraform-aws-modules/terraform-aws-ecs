################################################################################
# Service
################################################################################

output "id" {
  description = "ARN that identifies the service"
  value       = try(aws_ecs_service.this[0].id, aws_ecs_service.ignore_task_definition[0].id, null)
}

output "name" {
  description = "Name of the service"
  value       = try(aws_ecs_service.this[0].name, aws_ecs_service.ignore_task_definition[0].name, null)
}

################################################################################
# IAM Role
################################################################################

output "iam_role_name" {
  description = "Service IAM role name"
  value       = try(aws_iam_role.service[0].name, null)
}

output "iam_role_arn" {
  description = "Service IAM role ARN"
  value       = try(aws_iam_role.service[0].arn, var.iam_role_arn)
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the service IAM role"
  value       = try(aws_iam_role.service[0].unique_id, null)
}

################################################################################
# Container Definition
################################################################################

output "container_definitions" {
  description = "Container definitions"
  value       = module.container_definition
}

################################################################################
# Task Definition
################################################################################

output "task_definition_arn" {
  description = "Full ARN of the Task Definition (including both `family` and `revision`)"
  value       = try(aws_ecs_task_definition.this[0].arn, var.task_definition_arn)
}

output "task_definition_revision" {
  description = "Revision of the task in a particular family"
  value       = try(aws_ecs_task_definition.this[0].revision, null)
}

output "task_definition_family" {
  description = "The unique name of the task definition"
  value       = try(aws_ecs_task_definition.this[0].family, null)
}

output "task_definition_family_revision" {
  description = "The family and revision (family:revision) of the task definition"
  value       = "${try(aws_ecs_task_definition.this[0].family, "")}:${local.max_task_def_revision}"
}

################################################################################
# Task Execution - IAM Role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
################################################################################

output "task_exec_iam_role_name" {
  description = "Task execution IAM role name"
  value       = try(aws_iam_role.task_exec[0].name, null)
}

output "task_exec_iam_role_arn" {
  description = "Task execution IAM role ARN"
  value       = try(aws_iam_role.task_exec[0].arn, var.task_exec_iam_role_arn)
}

output "task_exec_iam_role_unique_id" {
  description = "Stable and unique string identifying the task execution IAM role"
  value       = try(aws_iam_role.task_exec[0].unique_id, null)
}

################################################################################
# Tasks - IAM role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html
################################################################################

output "tasks_iam_role_name" {
  description = "Tasks IAM role name"
  value       = try(aws_iam_role.tasks[0].name, null)
}

output "tasks_iam_role_arn" {
  description = "Tasks IAM role ARN"
  value       = try(aws_iam_role.tasks[0].arn, var.tasks_iam_role_arn)
}

output "tasks_iam_role_unique_id" {
  description = "Stable and unique string identifying the tasks IAM role"
  value       = try(aws_iam_role.tasks[0].unique_id, null)
}

################################################################################
# Task Set
################################################################################

output "task_set_id" {
  description = "The ID of the task set"
  value       = try(aws_ecs_task_set.this[0].task_set_id, aws_ecs_task_set.ignore_task_definition[0].task_set_id, null)
}

output "task_set_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the task set"
  value       = try(aws_ecs_task_set.this[0].arn, aws_ecs_task_set.ignore_task_definition[0].arn, null)
}

output "task_set_stability_status" {
  description = "The stability status. This indicates whether the task set has reached a steady state"
  value       = try(aws_ecs_task_set.this[0].stability_status, aws_ecs_task_set.ignore_task_definition[0].stability_status, null)
}

output "task_set_status" {
  description = "The status of the task set"
  value       = try(aws_ecs_task_set.this[0].status, aws_ecs_task_set.ignore_task_definition[0].status, null)
}

################################################################################
# Autoscaling
################################################################################

output "autoscaling_policies" {
  description = "Map of autoscaling policies and their attributes"
  value       = aws_appautoscaling_policy.this
}

output "autoscaling_scheduled_actions" {
  description = "Map of autoscaling scheduled actions and their attributes"
  value       = aws_appautoscaling_scheduled_action.this
}

################################################################################
# Security Group
################################################################################

output "security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = try(aws_security_group.this[0].arn, null)
}

output "security_group_id" {
  description = "ID of the security group"
  value       = try(aws_security_group.this[0].id, null)
}
