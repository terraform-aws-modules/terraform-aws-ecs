resource "aws_cloudwatch_log_group" "hello-world" {
  name              = "hello-world"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "hello-world" {
  family = "hello-world"

  container_definitions = <<EOF
[
  {
    "name": "hello-world",
    "image": "hello-world",
    "cpu": 0,
    "memory": 128,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "eu-west-1",
        "awslogs-group": "hello-world",
        "awslogs-stream-prefix": "my-ecs"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "hello-world" {
  name            = "hello-world"
  cluster         = "${var.cluser_id}"
  task_definition = "${aws_ecs_task_definition.hello-world.arn}"

  desired_count = 1

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}
