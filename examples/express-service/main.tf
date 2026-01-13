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

# ECS holds on to the service names for indefinitely
# And people wonder why ECS isn't used more ¯\_(ツ)_/¯
resource "random_string" "random" {
  length  = 6
  special = false
}

locals {
  region = "eu-west-1"
  name   = "ex-${basename(path.cwd)}-${random_string.random.result}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  container_port = 3000

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecs"
  }
}

################################################################################
# Service
################################################################################

module "ecs_express_service" {
  source = "../../modules/express-service"

  name = local.name

  cpu    = 1024
  memory = 4096

  network_configuration = {
    subnets = module.vpc.private_subnets
  }

  primary_container = {
    container_port = local.container_port
    image          = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
  }

  scaling_target = {
    auto_scaling_metric       = "AVERAGE_CPU"
    auto_scaling_target_value = "80"
    max_task_count            = 3
    min_task_count            = 1
  }

  # Security Group
  vpc_id = module.vpc.vpc_id
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = local.tags
}

module "ecs_express_service_disabled" {
  source = "../../modules/express-service"

  create = false
}

################################################################################
# Supporting Resources
################################################################################

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
