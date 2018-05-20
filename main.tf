terraform {
  required_version = ">= 0.11.7"
}

provider "template" {
  version = ">= 1.0.0"
}

resource "aws_ecs_cluster" "this" {
  count = "${var.create_ecs ? 1 : 0}"

  name = "${var.name}"
}
