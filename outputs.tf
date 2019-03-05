output "this_ecs_cluster_id" {
  value = "${element(concat(aws_ecs_cluster.this.*.id, list("")), 0)}"
}

output "this_ecs_cluster_arn" {
  value = "${element(concat(aws_ecs_cluster.this.*.arn, list("")), 0)}"
}

output "this_ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = "${var.name}"
}
