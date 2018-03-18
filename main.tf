terraform {
  required_version = ">= 0.11.4"
}

resource "aws_ecs_cluster" "ecs" {
  count = "${var.create_ecs ? 1 : 0}"

  name = "${var.name}"
}
