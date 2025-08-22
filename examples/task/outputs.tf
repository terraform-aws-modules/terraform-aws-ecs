################################################################################
# Task Module
################################################################################

output "task_definition_arn" {
  description = "Full ARN of the task definition"
  value       = module.ecs_task.task_definition_arn
}

output "task_definition_family" {
  description = "The unique name of the task definition"
  value       = module.ecs_task.task_definition_family
}

output "task_exec_iam_role_arn" {
  description = "Task execution IAM role ARN"
  value       = module.ecs_task.task_exec_iam_role_arn
}

output "tasks_iam_role_arn" {
  description = "Tasks IAM role ARN"
  value       = module.ecs_task.tasks_iam_role_arn
}

################################################################################
# Complete Module
################################################################################

output "cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = module.ecs_complete.cluster_arn
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = module.ecs_complete.cluster_id
}

output "cluster_name" {
  description = "Name that identifies the cluster"
  value       = module.ecs_complete.cluster_name
}

output "tasks" {
  description = "Map of tasks created and their attributes"
  value       = module.ecs_complete.tasks
}
