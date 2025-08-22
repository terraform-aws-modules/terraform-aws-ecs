provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
  name   = "ex-${basename(path.cwd)}"

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecs"
  }
}

################################################################################
# ECS Module - Task Only
################################################################################

module "ecs_task" {
  source = "../../modules/task"

  name = "${local.name}-task"

  # Container definitions
  container_definitions = {
    nginx = {
      cpu       = 256
      memory    = 512
      essential = true
      image     = "public.ecr.aws/nginx/nginx:latest"
      portMappings = [
        {
          name          = "nginx"
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      # Enable logging
      enable_cloudwatch_logging              = true
      create_cloudwatch_log_group            = true
      cloudwatch_log_group_retention_in_days = 1
    }
  }

  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  runtime_platform = {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  # Task execution role
  create_task_exec_iam_role = true

  # Task role
  create_tasks_iam_role = true

  tags = local.tags
}

################################################################################
# ECS Module - Complete (Cluster + Task)
################################################################################

module "ecs_complete" {
  source = "../../"

  cluster_name = local.name

  # Task definitions
  tasks = {
    standalone-task = {
      name = "${local.name}-standalone"

      container_definitions = {
        httpd = {
          cpu       = 256
          memory    = 512
          essential = true
          image     = "public.ecr.aws/docker/library/httpd:latest"
          portMappings = [
            {
              name          = "httpd"
              containerPort = 80
              protocol      = "tcp"
            }
          ]

          enable_cloudwatch_logging              = true
          create_cloudwatch_log_group            = true
          cloudwatch_log_group_retention_in_days = 1
        }
      }

      cpu                      = 512
      memory                   = 1024
      requires_compatibilities = ["FARGATE"]
      network_mode             = "awsvpc"

      create_task_exec_iam_role = true
      create_tasks_iam_role     = true
    }
  }

  tags = local.tags
}
