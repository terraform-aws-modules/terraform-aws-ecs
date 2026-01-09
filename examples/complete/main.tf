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

module "ecs" {
  source = "../../"

  cluster_name = local.name

  # Cluster capacity providers
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

  capacity_providers = {
    ASG = {
      auto_scaling_group_provider = {
        auto_scaling_group_arn         = module.autoscaling.autoscaling_group_arn
        managed_draining               = "ENABLED"
        managed_termination_protection = "ENABLED"

        managed_scaling = {
          maximum_scaling_step_size = 5
          minimum_scaling_step_size = 1
          status                    = "ENABLED"
          target_capacity           = 60
        }
      }
    }
  }

  services = {
    ecsdemo-frontend = {
      cpu    = 1024
      memory = 4096

      autoscaling_policies = {
        predictive = {
          policy_type = "PredictiveScaling"
          predictive_scaling_policy_configuration = {
            mode = "ForecastOnly"
            metric_specification = [{
              target_value = 60
              customized_scaling_metric_specification = {
                metric_data_query = [
                  {
                    id = "cpu_util"
                    metric_stat = {
                      stat = "Average"
                      metric = {
                        metric_name = "CPUUtilization"
                        namespace   = "AWS/ECS"
                        dimension = [
                          {
                            name  = "ServiceName"
                            value = "ecsdemo-frontend"
                          },
                          {
                            name  = "ClusterName"
                            value = "ex-complete"
                          }
                        ]
                      }
                    }
                    return_data = true
                  }
                ]
              }
              predefined_load_metric_specification = {
                predefined_metric_type = "ECSServiceTotalCPUUtilization"
              }
              # predefined_scaling_metric_specification = {
              #   predefined_metric_type = "ECSServiceAverageMemoryUtilization"
              # }
              # predefined_metric_pair_specification = {
              #   predefined_metric_type = "ECSServiceMemoryUtilization"
              # }
            }]
          }
        }
      }

      # Container definition(s)
      container_definitions = {

        fluent-bit = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = nonsensitive(data.aws_ssm_parameter.fluentbit.value)
          user      = "0"
          firelensConfiguration = {
            type = "fluentbit"
          }
          memoryReservation = 50

          cloudwatch_log_group_retention_in_days = 30
        }

        (local.container_name) = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"

          healthCheck = {
            command = ["CMD-SHELL", "curl -f http://localhost:${local.container_port}/health || exit 1"]
          }

          portMappings = [
            {
              name          = local.container_name
              containerPort = local.container_port
              hostPort      = local.container_port
              protocol      = "tcp"
            }
          ]

          capacity_provider_strategy = {
            ASG = {
              base              = 20
              capacity_provider = "ASG"
              weight            = 50
            }
          }

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
          memoryReservation = 100

          restartPolicy = {
            enabled              = true
            ignoredExitCodes     = [1]
            restartAttemptPeriod = 60
          }
        }
      }

      # Linear deployment
      deployment_configuration = {
        strategy = "LINEAR"

        linear_configuration = {
          step_percent              = 20
          step_bake_time_in_minutes = 1
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
            # Example TLS configuration
            # tls = {
            #   issuer_cert_authority = {
            #     aws_pca_authority_arn = aws_acmpca_certificate_authority.this.arn
            #   }
            #   role_arn = module.tls_role.iam_role_arn
            #   kms_key = module.tls_role.kms_key_arn
            # }
          }
        ]
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["ex-ecs"].arn
          container_name   = local.container_name
          container_port   = local.container_port

          advanced_configuration = {
            alternate_target_group_arn = module.alb.target_groups["ex-ecs-alt"].arn
            production_listener_rule   = module.alb.listener_rules["ex-http/ex-forward"].arn
          }
        }
      }

      tasks_iam_role_name                 = "${local.name}-tasks"
      tasks_iam_role_description          = "Example tasks IAM role for ${local.name}"
      tasks_iam_role_max_session_duration = 7200

      tasks_iam_role_policies = {
        ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      }
      tasks_iam_role_statements = [
        {
          actions   = ["s3:List*"]
          resources = ["arn:aws:s3:::*"]
        }
      ]

      subnet_ids                    = module.vpc.private_subnets
      vpc_id                        = module.vpc.vpc_id
      availability_zone_rebalancing = "ENABLED"
      security_group_ingress_rules = {
        alb_3000 = {
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
    }
  }

  tags = local.tags
}

module "ecs_disabled" {
  source = "../../"

  create = false
}

module "ecs_cluster_disabled" {
  source = "../../modules/cluster"

  create = false
}

module "service_disabled" {
  source = "../../modules/service"

  create = false
}

################################################################################
# Supporting Resources
################################################################################

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html#ecs-optimized-ami-linux
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended"
}

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

      forward = {
        target_group_key = "ex-ecs"
      }

      rules = {
        ex-forward = {
          priority = 100
          actions = [{
            forward = {
              target_group_key = "ex-ecs"
            }
          }]
          conditions = [{
            path_pattern = {
              values = ["/"]
            }
          }]
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

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
    ex-ecs-alt = {
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

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 9.0"

  name = local.name

  image_id      = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type = "t3.large"

  security_groups = [module.autoscaling_sg.security_group_id]
  user_data = base64encode(<<-EOT
    #!/bin/bash

    cat <<'EOF' >> /etc/ecs/ecs.config
    ECS_CLUSTER=${local.name}
    ECS_LOGLEVEL=debug
    ECS_CONTAINER_INSTANCE_TAGS=${jsonencode(local.tags)}
    ECS_ENABLE_TASK_IAM_ROLE=true
    EOF
  EOT
  )
  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = local.name
  iam_role_description        = "ECS role for ${local.name}"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = "EC2"
  min_size            = 1
  max_size            = 5
  desired_capacity    = 2

  # https://github.com/hashicorp/terraform-provider-aws/issues/12582
  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = true

  tags = local.tags
}

module "autoscaling_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  description = "Autoscaling group security group"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]

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
