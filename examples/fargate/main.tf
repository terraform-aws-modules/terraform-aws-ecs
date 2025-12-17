provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  region = "eu-west-1"
  name   = "ex-${basename(path.cwd)}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  container_name = "ecsdemo-frontend"
  container_port = 3000

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecs"
  }
}

################################################################################
# Cluster
################################################################################

module "ecs_cluster" {
  source = "../../modules/cluster"

  name = local.name

  # Capacity provider
  cluster_capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 20
    }
    FARGATE_SPOT = {
      weight = 50
    }
  }

  tags = local.tags
}

################################################################################
# Service
################################################################################

module "ecs_service" {
  source = "../../modules/service"

  name        = local.name
  cluster_arn = module.ecs_cluster.arn

  cpu    = 1024
  memory = 4096

  # Enables ECS Exec
  enable_execute_command = true

  # Blue/green deployment
  deployment_configuration = {
    strategy             = "BLUE_GREEN"
    bake_time_in_minutes = 2

    # # Example config using lifecycle hooks
    # lifecycle_hook = {
    #   success = {
    #     hook_target_arn  = aws_lambda_function.hook_success.arn
    #     role_arn         = aws_iam_role.global.arn
    #     lifecycle_stages = ["POST_SCALE_UP", "POST_TEST_TRAFFIC_SHIFT"]
    #     hook_details     = jsonencode("test")
    #   }
    #   failure = {
    #     hook_target_arn  = aws_lambda_function.hook_failure.arn
    #     role_arn         = aws_iam_role.global.arn
    #     lifecycle_stages = ["TEST_TRAFFIC_SHIFT", "POST_PRODUCTION_TRAFFIC_SHIFT"]
    #   }
    # }
  }

  # Container definition(s)
  container_definitions = {

    fluent-bit = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = nonsensitive(data.aws_ssm_parameter.fluentbit.value)
      firelensConfiguration = {
        type = "fluentbit"
      }
      memoryReservation = 50
      user              = "0"
    }

    (local.container_name) = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
      portMappings = [
        {
          name          = local.container_name
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
        }
      ]

      # Example image used requires access to write to root filesystem
      readonlyRootFilesystem = false

      dependsOn = [{
        containerName = "fluent-bit"
        condition     = "START"
      }]

      enable_cloudwatch_logging = false
      logConfiguration = {
        logDriver = "awsfirelens"
        options = {
          Name                    = "stdout"
          log-driver-buffer-limit = "2097152"
        }
      }

      linuxParameters = {
        capabilities = {
          add = []
          drop = [
            "NET_RAW"
          ]
        }
      }

      restartPolicy = {
        enabled              = true
        ignoredExitCodes     = [1]
        restartAttemptPeriod = 60
      }

      # Not required for fluent-bit, just an example
      volumesFrom = [{
        sourceContainer = "fluent-bit"
        readOnly        = false
      }]

      memoryReservation = 100
    }
  }

  service_connect_configuration = {
    namespace = aws_service_discovery_http_namespace.this.arn
    service = [
      {
        client_alias = {
          port     = local.container_port
          dns_name = local.container_name
        }
        port_name      = local.container_name
        discovery_name = local.container_name
      }
    ]
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["ex-ecs"].arn
      container_name   = local.container_name
      container_port   = local.container_port

      # for blue/green deployments
      advanced_configuration = {
        alternate_target_group_arn = module.alb.target_groups["ex-ecs-alternate"].arn
        production_listener_rule   = module.alb.listener_rules["ex-http/production"].arn
        test_listener_rule         = module.alb.listener_rules["ex-http/test"].arn
      }
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_ingress_rules = {
    alb_3000 = {
      description                  = "Service port"
      from_port                    = local.container_port
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.alb.security_group_id
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  service_tags = {
    "ServiceTag" = "Tag on service level"
  }

  tags = local.tags
}

################################################################################
# Standalone Task Definition (w/o Service)
################################################################################

module "ecs_task_definition" {
  source = "../../modules/service"

  # Service
  name           = "${local.name}-standalone"
  cluster_arn    = module.ecs_cluster.arn
  create_service = false

  # Task Definition
  volume = {
    ex-vol = {}
  }

  runtime_platform = {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  # Container definition(s)
  container_definitions = {
    al2023 = {
      image = "public.ecr.aws/amazonlinux/amazonlinux:2023-minimal"

      mountPoints = [
        {
          sourceVolume  = "ex-vol",
          containerPath = "/var/www/ex-vol"
        }
      ]

      command    = ["echo hello world"]
      entrypoint = ["/usr/bin/sh", "-c"]
    }
  }

  subnet_ids = module.vpc.private_subnets

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

data "aws_ssm_parameter" "fluentbit" {
  name = "/aws/service/aws-for-fluent-bit/stable"
}

resource "aws_service_discovery_http_namespace" "this" {
  name        = local.name
  description = "CloudMap namespace for ${local.name}"
  tags        = local.tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.0"

  name = local.name

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  listeners = {
    ex-http = {
      port     = 80
      protocol = "HTTP"

      fixed_response = {
        content_type = "text/plain"
        message_body = "404: Page not found"
        status_code  = "404"
      }

      # for blue/green deployments
      rules = {
        production = {
          priority = 1
          actions = [
            {
              weighted_forward = {
                target_groups = [
                  {
                    target_group_key = "ex-ecs"
                    weight           = 100
                  },
                  {
                    target_group_key = "ex-ecs-alternate"
                    weight           = 0
                  }
                ]
              }
            }
          ]
          conditions = [
            {
              path_pattern = {
                values = ["/*"]
              }
            }
          ]
        }
        test = {
          priority = 2
          actions = [
            {
              weighted_forward = {
                target_groups = [
                  {
                    target_group_key = "ex-ecs-alternate"
                    weight           = 100
                  }
                ]
              }
            }
          ]
          conditions = [
            {
              path_pattern = {
                values = ["/*"]
              }
            }
          ]
        }
      }
    }
  }

  target_groups = {
    ex-ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = local.container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # There's nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }

    # for blue/green deployments
    ex-ecs-alternate = {
      backend_protocol                  = "HTTP"
      backend_port                      = local.container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # There's nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }

  tags = local.tags
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}
