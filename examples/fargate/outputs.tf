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

################################################################################
# Cluster Capacity Providers
################################################################################

output "cluster_capacity_providers" {
  description = "Map of cluster capacity providers attributes"
  value       = module.ecs.cluster_capacity_providers
}

################################################################################
# Capacity Provider
################################################################################

output "autoscaling_capacity_providers" {
  description = "Map of capacity providers created and their attributes"
  value       = module.ecs.autoscaling_capacity_providers
}

################################################################################
# Service
################################################################################

output "id" {
  description = "ARN that identifies the service"
  value       = module.service.id
}

output "name" {
  description = "Name of the service"
  value       = module.service.name
}

################################################################################
# IAM Role
################################################################################

output "iam_role_name" {
  description = "Service IAM role name"
  value       = module.service.iam_role_name
}

output "iam_role_arn" {
  description = "Service IAM role ARN"
  value       = module.service.iam_role_arn
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the service IAM role"
  value       = module.service.iam_role_unique_id
}
