################################################################################
# Service
################################################################################

output "id" {
  description = "ARN that identifies the service"
  value       = try(aws_ecs_service.this[0].id, aws_ecs_service.idc[0].id, null)
}

output "name" {
  description = "Name of the service"
  value       = try(aws_ecs_service.this[0].name, aws_ecs_service.idc[0].name, null)
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
  value       = try(aws_iam_role.service[0].arn, null)
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the service IAM role"
  value       = try(aws_iam_role.service[0].unique_id, null)
}

################################################################################
# Task Definition
################################################################################

output "task_definition_arn" {
  description = "Full ARN of the Task Definition (including both `family` and `revision`)"
  value       = try(aws_ecs_task_definition.this[0].arn, null)
}

output "task_definition_revision" {
  description = "Revision of the task in a particular family"
  value       = try(aws_ecs_task_definition.this[0].revision, null)
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
  value       = try(aws_iam_role.task_exec[0].arn, null)
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
  description = "Tasjs IAM role name"
  value       = try(aws_iam_role.tasks[0].name, null)
}

output "tasks_iam_role_arn" {
  description = "Tasks IAM role ARN"
  value       = try(aws_iam_role.tasks[0].arn, null)
}

output "tasks_iam_role_unique_id" {
  description = "Stable and unique string identifying the tasks IAM role"
  value       = try(aws_iam_role.tasks[0].unique_id, null)
}
