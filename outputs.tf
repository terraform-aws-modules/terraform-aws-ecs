output "this_ecs_cluster_id" {
  value = concat(aws_ecs_cluster.this.*.id, [""])[0]
}

output "this_ecs_cluster_arn" {
  value = concat(aws_ecs_cluster.this.*.arn, [""])[0]
}

output "this_ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = var.name
}
