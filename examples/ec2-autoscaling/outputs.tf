################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = module.ecs_cluster.arn
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = module.ecs_cluster.id
}

output "cluster_name" {
  description = "Name that identifies the cluster"
  value       = module.ecs_cluster.name
}

output "cloudwatch_log_group_name" {
  description = "Name of CloudWatch log group created"
  value       = module.ecs_cluster.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of CloudWatch log group created"
  value       = module.ecs_cluster.cloudwatch_log_group_arn
}

output "cluster_capacity_providers" {
  description = "Map of cluster capacity providers attributes"
  value       = module.ecs_cluster.cluster_capacity_providers
}

output "capacity_providers" {
  description = "Map of autoscaling capacity providers created and their attributes"
  value       = module.ecs_cluster.capacity_providers
}

output "task_exec_iam_role_name" {
  description = "Task execution IAM role name"
  value       = module.ecs_cluster.task_exec_iam_role_name
}

output "task_exec_iam_role_arn" {
  description = "Task execution IAM role ARN"
  value       = module.ecs_cluster.task_exec_iam_role_arn
}

output "task_exec_iam_role_unique_id" {
  description = "Stable and unique string identifying the task execution IAM role"
  value       = module.ecs_cluster.task_exec_iam_role_unique_id
}

output "infrastructure_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.ecs_cluster.infrastructure_iam_role_arn
}

output "infrastructure_iam_role_name" {
  description = "IAM role name"
  value       = module.ecs_cluster.infrastructure_iam_role_name
}

output "infrastructure_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.ecs_cluster.infrastructure_iam_role_unique_id
}

output "node_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.ecs_cluster.node_iam_role_arn
}

output "node_iam_role_name" {
  description = "IAM role name"
  value       = module.ecs_cluster.node_iam_role_name
}

output "node_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.ecs_cluster.node_iam_role_unique_id
}

output "node_iam_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = module.ecs_cluster.node_iam_instance_profile_arn
}

output "node_iam_instance_profile_id" {
  description = "Instance profile's ID"
  value       = module.ecs_cluster.node_iam_instance_profile_id
}

output "node_iam_instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = module.ecs_cluster.node_iam_instance_profile_unique
}

################################################################################
# Service
################################################################################

output "service_id" {
  description = "ARN that identifies the service"
  value       = module.ecs_service.id
}

output "service_name" {
  description = "Name of the service"
  value       = module.ecs_service.name
}

output "service_iam_role_name" {
  description = "Service IAM role name"
  value       = module.ecs_service.iam_role_name
}

output "service_iam_role_arn" {
  description = "Service IAM role ARN"
  value       = module.ecs_service.iam_role_arn
}

output "service_iam_role_unique_id" {
  description = "Stable and unique string identifying the service IAM role"
  value       = module.ecs_service.iam_role_unique_id
}

output "service_container_definitions" {
  description = "Container definitions"
  value       = module.ecs_service.container_definitions
}

output "service_task_definition_arn" {
  description = "Full ARN of the Task Definition (including both `family` and `revision`)"
  value       = module.ecs_service.task_definition_arn
}

output "service_task_definition_revision" {
  description = "Revision of the task in a particular family"
  value       = module.ecs_service.task_definition_revision
}

output "service_task_exec_iam_role_name" {
  description = "Task execution IAM role name"
  value       = module.ecs_service.task_exec_iam_role_name
}

output "service_task_exec_iam_role_arn" {
  description = "Task execution IAM role ARN"
  value       = module.ecs_service.task_exec_iam_role_arn
}

output "service_task_exec_iam_role_unique_id" {
  description = "Stable and unique string identifying the task execution IAM role"
  value       = module.ecs_service.task_exec_iam_role_unique_id
}

output "service_tasks_iam_role_name" {
  description = "Tasks IAM role name"
  value       = module.ecs_service.tasks_iam_role_name
}

output "service_tasks_iam_role_arn" {
  description = "Tasks IAM role ARN"
  value       = module.ecs_service.tasks_iam_role_arn
}

output "service_tasks_iam_role_unique_id" {
  description = "Stable and unique string identifying the tasks IAM role"
  value       = module.ecs_service.tasks_iam_role_unique_id
}

output "service_task_set_id" {
  description = "The ID of the task set"
  value       = module.ecs_service.task_set_id
}

output "service_task_set_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the task set"
  value       = module.ecs_service.task_set_arn
}

output "service_task_set_stability_status" {
  description = "The stability status. This indicates whether the task set has reached a steady state"
  value       = module.ecs_service.task_set_stability_status
}

output "service_task_set_status" {
  description = "The status of the task set"
  value       = module.ecs_service.task_set_status
}

output "service_autoscaling_policies" {
  description = "Map of autoscaling policies and their attributes"
  value       = module.ecs_service.autoscaling_policies
}

output "service_autoscaling_scheduled_actions" {
  description = "Map of autoscaling scheduled actions and their attributes"
  value       = module.ecs_service.autoscaling_scheduled_actions
}

output "service_infrastructure_iam_role_arn" {
  description = "Infrastructure IAM role ARN"
  value       = module.ecs_service.infrastructure_iam_role_arn
}

output "service_infrastructure_iam_role_name" {
  description = "Infrastructure IAM role name"
  value       = module.ecs_service.infrastructure_iam_role_name
}

################################################################################
# Application Load Balancer
################################################################################

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.dns_name
}
