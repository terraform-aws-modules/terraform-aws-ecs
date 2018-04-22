provider "aws" {
  region  = "eu-west-1"
  version = "v1.15.0"
}

provider "terraform" {}

locals {
  name = "my-ecs"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v1.30.0"

  name = "${local.name}"

  cidr = "10.1.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.11.0/24", "10.1.12.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "${local.name}"
    Name        = "${local.name}"
  }
}

module "ecs" {
  source = "../../"
  name   = "${local.name}"
}

module "ec2" {
  source              = "../../modules/ec2-instances"
  ecs_cluster         = "${local.name}"
  vpc_zone_identifier = ["${module.vpc.private_subnets}"]
  security_groups     = ["${module.vpc.default_security_group_id}"]
}
