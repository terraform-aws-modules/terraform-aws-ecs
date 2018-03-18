module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v1.26.0"

  name = "my-ecs"

  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.11.0/24", "10.1.12.0/24"]

  enable_nat_gateway = false #This needs to be true eventually otherwise ECS agent will not work

  tags = {
    Environment = "my-ecs"
    Name        = "my-ecs"
  }
}

module "ecs" {
  source = "../../"
  name   = "my-ecs"
}
