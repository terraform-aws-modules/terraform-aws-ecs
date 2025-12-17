provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  region = "eu-west-1"
  name   = "ex-${basename(path.cwd)}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  container_name = "ecs-sample"
  container_port = 80

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

  capacity_providers = {
    mi-example = {
      managed_instances_provider = {
        instance_launch_template = {
          instance_requirements = {
            instance_generations = ["current"]
            cpu_manufacturers    = ["intel", "amd"]

            memory_mib = {
              max = 8192
              min = 1024
            }

            vcpu_count = {
              max = 4
              min = 1
            }
          }

          network_configuration = {
            subnets = module.vpc.private_subnets
          }

          storage_configuration = {
            storage_size_gib = 30
          }
        }
      }
    }
  }

  # Managed instances security group
  vpc_id = module.vpc.vpc_id
  security_group_ingress_rules = {
    alb_http = {
      from_port                    = local.container_port
      description                  = "Service port"
      referenced_security_group_id = module.alb.security_group_id
    }
  }
  security_group_egress_rules = {
    all = {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "-1"
    }
  }

  tags = local.tags
}

################################################################################
# Service
################################################################################

module "ecs_service" {
  source = "../../modules/service"

  # Service
  name        = local.name
  cluster_arn = module.ecs_cluster.arn

  # Task Definition
  requires_compatibilities = ["MANAGED_INSTANCES"]
  launch_type              = "EC2"

  # Container definition(s)
  container_definitions = {
    (local.container_name) = {
      image = "public.ecr.aws/docker/library/httpd:latest"

      essential  = true
      entrypoint = ["sh", "-c"]
      command    = ["/bin/sh -c \"echo '<html><head><title>Amazon ECS Sample App</title><style>body {margin-top: 40px; background-color: #333;} </style></head><body><div style=color:white;text-align:center><h1>Amazon ECS Sample App</h1><h2>Congratulations!</h2><p>Your application is now running on a container in Amazon ECS using Amazon ECS Managed Instances.</p></div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""]

      cpu    = 256
      memory = 512

      readonlyRootFilesystem = false

      portMappings = [
        {
          name          = local.container_name
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
        }
      ]
    }
  }

  capacity_provider_strategy = {
    # On-demand instances
    mi-example = {
      capacity_provider = module.ecs_cluster.capacity_providers["mi-example"].name
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["ex-ecs"].arn
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_ingress_rules = {
    alb_http = {
      from_port                    = local.container_port
      description                  = "Service port"
      referenced_security_group_id = module.alb.security_group_id
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

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
      from_port   = local.container_port
      to_port     = local.container_port
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
      port     = local.container_port
      protocol = "HTTP"

      forward = {
        target_group_key = "ex-ecs"
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

      # Theres nothing to attach here in this definition. Instead,
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
