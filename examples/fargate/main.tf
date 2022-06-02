provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
  name   = "ecs-ex-${replace(basename(path.cwd), "_", "-")}"

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecs"
  }
}

################################################################################
# Ecs Module
################################################################################

module "ecs_disabled" {
  source = "../.."

  create = false
}

module "ecs" {
  source = "../.."

  cluster_name = local.name
  cluster_configuration = {
    execute_command_configuration = {
      kms_key_id = aws_kms_key.example.arn
      logging    = "OVERRIDE"
    }
  }

  # Capacity provider
  cluster_capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  cluster_default_capacity_provider_strategy = [
    {

      capacity_provider = "FARGATE"
      weight            = 50
    },
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 50
    }
  ]

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  create_vpc = false

  name = local.name
  cidr = "10.99.0.0/18"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets  = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]

  enable_nat_gateway      = true
  single_nat_gateway      = true
  map_public_ip_on_launch = false

  tags = local.tags
}

resource "aws_kms_key" "example" {
  description             = local.name
  deletion_window_in_days = 7

  tags = local.tags
}
