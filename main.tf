resource "aws_ecs_cluster" "this" {
  count = var.create_ecs ? 1 : 0

  name = var.name
  setting = {
    name  = "containerInsights"
    value = var.create_ecs ? "enabled" : "disabled"
  }

  tags = var.tags
}
