################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = module.cluster.arn
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = module.cluster.id
}

output "cluster_name" {
  description = "Name that identifies the cluster"
  value       = module.cluster.name
}

output "cloudwatch_log_group_name" {
  description = "Name of CloudWatch log group created"
  value       = module.cluster.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of CloudWatch log group created"
  value       = module.cluster.cloudwatch_log_group_arn
}

output "cluster_capacity_providers" {
  description = "Map of cluster capacity providers attributes"
  value       = module.cluster.cluster_capacity_providers
}

output "capacity_providers" {
  description = "Map of autoscaling capacity providers created and their attributes"
  value       = module.cluster.capacity_providers
}

output "task_exec_iam_role_name" {
  description = "Task execution IAM role name"
  value       = module.cluster.task_exec_iam_role_name
}

output "task_exec_iam_role_arn" {
  description = "Task execution IAM role ARN"
  value       = module.cluster.task_exec_iam_role_arn
}

output "task_exec_iam_role_unique_id" {
  description = "Stable and unique string identifying the task execution IAM role"
  value       = module.cluster.task_exec_iam_role_unique_id
}

output "infrastructure_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.cluster.infrastructure_iam_role_arn
}

output "infrastructure_iam_role_name" {
  description = "IAM role name"
  value       = module.cluster.infrastructure_iam_role_name
}

output "infrastructure_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.cluster.infrastructure_iam_role_unique_id
}

output "node_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.cluster.node_iam_role_arn
}

output "node_iam_role_name" {
  description = "IAM role name"
  value       = module.cluster.node_iam_role_name
}

output "node_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.cluster.node_iam_role_unique_id
}

output "node_iam_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = module.cluster.node_iam_instance_profile_arn
}

output "node_iam_instance_profile_id" {
  description = "Instance profile's ID"
  value       = module.cluster.node_iam_instance_profile_id
}

output "node_iam_instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = module.cluster.node_iam_instance_profile_unique
}

################################################################################
# Service(s)
################################################################################

output "services" {
  description = "Map of services created and their attributes"
  value       = module.service
}
