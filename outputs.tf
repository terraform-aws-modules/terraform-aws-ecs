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
# CloudWatch Log Group
################################################################################

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = try(aws_cloudwatch_log_group.this[0].name, null)
}

output "cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = try(aws_cloudwatch_log_group.this[0].arn, null)
}

################################################################################
# Capacity Provider - Autoscaling Group(s)
################################################################################

output "capacity_providers" {
  description = "Map of capacity providers created and their attributes"
  value       = aws_ecs_capacity_provider.this
}
