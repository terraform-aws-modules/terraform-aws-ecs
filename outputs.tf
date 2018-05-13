output "ecs_cluster_id" {
  value = "${aws_ecs_cluster.ecs.0.id}"
}
