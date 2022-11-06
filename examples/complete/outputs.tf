################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = module.ecs.cluster_arn
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = module.ecs.cluster_id
}

output "cluster_name" {
  description = "Name that identifies the cluster"
  value       = module.ecs.cluster_name
}

output "cluster_capacity_providers" {
  description = "Map of cluster capacity providers attributes"
  value       = module.ecs.cluster_capacity_providers
}

output "cluster_autoscaling_capacity_providers" {
  description = "Map of capacity providers created and their attributes"
  value       = module.ecs.autoscaling_capacity_providers
}

################################################################################
# Service
################################################################################

output "service_id" {
  description = "ARN that identifies the service"
  value       = module.service.id
}

output "service_name" {
  description = "Name of the service"
  value       = module.service.name
}

output "service_iam_role_name" {
  description = "Service IAM role name"
  value       = module.service.iam_role_name
}

output "service_iam_role_arn" {
  description = "Service IAM role ARN"
  value       = module.service.iam_role_arn
}

output "service_iam_role_unique_id" {
  description = "Stable and unique string identifying the service IAM role"
  value       = module.service.iam_role_unique_id
}

output "service_task_definition_arn" {
  description = "Full ARN of the Task Definition (including both `family` and `revision`)"
  value       = module.service.task_definition_arn
}

output "service_task_definition_revision" {
  description = "Revision of the task in a particular family"
  value       = module.service.task_definition_revision
}

output "service_task_exec_iam_role_name" {
  description = "Task execution IAM role name"
  value       = module.service.task_exec_iam_role_name
}

output "service_task_exec_iam_role_arn" {
  description = "Task execution IAM role ARN"
  value       = module.service.task_exec_iam_role_arn
}

output "service_task_exec_iam_role_unique_id" {
  description = "Stable and unique string identifying the task execution IAM role"
  value       = module.service.task_exec_iam_role_unique_id
}

output "service_tasks_iam_role_name" {
  description = "Tasjs IAM role name"
  value       = module.service.tasks_iam_role_name
}

output "service_tasks_iam_role_arn" {
  description = "Tasks IAM role ARN"
  value       = module.service.tasks_iam_role_arn
}

output "service_tasks_iam_role_unique_id" {
  description = "Stable and unique string identifying the tasks IAM role"
  value       = module.service.tasks_iam_role_unique_id
}

output "service_task_set_id" {
  description = "The ID of the task set"
  value       = module.service.task_set_id
}

output "service_task_set_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the task set"
  value       = module.service.task_set_arn
}

output "service_task_set_stability_status" {
  description = "The stability status. This indicates whether the task set has reached a steady state"
  value       = module.service.task_set_stability_status
}

output "service_task_set_status" {
  description = "The status of the task set"
  value       = module.service.task_set_status
}

output "service_autoscaling_policies" {
  description = "Map of autoscaling policies and their attributes"
  value       = module.service.autoscaling_policies
}

output "service_autoscaling_scheduled_actions" {
  description = "Map of autoscaling scheduled actions and their attributes"
  value       = module.service.autoscaling_scheduled_actions
}
