################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = try(aws_ecs_cluster.this[0].arn, null)
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = try(aws_ecs_cluster.this[0].id, null)
}

################################################################################
# Cluster Capacity Providers
################################################################################

output "cluster_capacity_providers" {
  description = "Map of cluster capacity providers attributes"
  value       = aws_ecs_cluster_capacity_providers.this
}

################################################################################
# Capacity Provider - Autoscaling Group(s)
################################################################################

output "capacity_providers" {
  description = "Map of capacity providers created and their attributes"
  value       = aws_ecs_capacity_provider.this
}
