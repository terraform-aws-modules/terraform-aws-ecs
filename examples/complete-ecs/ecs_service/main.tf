resource "aws_cloudwatch_log_group" "service" {
  name              = "ecs-${var.cluster_name}"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "service" {
  family = "${var.service}"

  container_definitions = <<EOF
[
  {
    "name": "${var.service}",
    "image": "${var.service}",
    "cpu": 0,
    "memory": 128,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "ecs-${var.cluster_name}",
        "awslogs-stream-prefix": "service"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "service" {
  name = "${var.service}"
  cluster = var.cluster_id
  task_definition = aws_ecs_task_definition.service.arn

  desired_count = 1

  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 0
}
