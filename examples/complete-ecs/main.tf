provider "aws" {
  region = "eu-west-1"
}

provider "terraform" {}

locals {
  name = "my-ecs"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

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

#----- ECS --------
module "ecs" {
  source = "../../"
  name   = "${local.name}"
}

module "ec2-profile" {
  source = "../../modules/ecs-instance-profile"
  name   = "my-ecs"
}

#----- ECS  Resources--------
module "ec2" {
  source              = "ec2-instances"
  ecs_cluster         = "${local.name}"
  vpc_zone_identifier = ["${module.vpc.private_subnets}"]
  security_groups     = ["${module.vpc.default_security_group_id}"]
  ec2_profile         = "${module.ec2-profile.instance_profile_id}"
}

#----- ECS  Services--------

module "hello-world" {
  source    = "service-hello-world"
  cluser_id = "${module.ecs.ecs_cluster_id}"
}
