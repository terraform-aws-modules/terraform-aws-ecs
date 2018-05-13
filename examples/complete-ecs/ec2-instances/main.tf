#For now we only use the AWS ECS optimized ami <https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html>
data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

# This is the convention we use to know wht belongs to each other
locals {
  name = "${var.ecs_cluster}-${var.environment}"
}

module "this" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "v2.2.2"

  name = "${local.name}"

  # Launch configuration
  lc_name = "${local.name}"

  image_id             = "${data.aws_ami.amazon_linux_ecs.id}"
  instance_type        = "t2.micro"
  security_groups      = "${var.security_groups}"
  iam_instance_profile = "${var.ec2_profile}"
  user_data            = "${data.template_file.user_data.rendered}"

  # Auto scaling group
  asg_name                  = "${local.name}"
  vpc_zone_identifier       = "${var.vpc_zone_identifier}"
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "${var.environment}"
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = "${var.ecs_cluster}"
      propagate_at_launch = true
    },
  ]
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user-data.sh")}"

  vars {
    cluster_name = "${var.ecs_cluster}"
  }
}
