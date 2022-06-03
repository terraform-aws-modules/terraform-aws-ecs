# Upgrade from v3.x to v4.x

Please consult the `examples` directory for reference example configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Minimum supported version of Terraform AWS provider updated to v4.6 to support the latest resources utilized
- Minimum supported version of Terraform updated to v1.0
- `ecs-instance-profile` sub-module has been removed; this functionality is available through the [`terraform-aws-modules/terraform-aws-autoscaling`](https://github.com/terraform-aws-modules/terraform-aws-autoscaling) module starting with version [v6.5.0](https://github.com/terraform-aws-modules/terraform-aws-autoscaling/pull/194). Please see the [`examples/ec2`](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/ec2) example for a demonstration on how to use and integrate with the `terraform-aws-autoscaling` module.
- The `container_insights` and `capacity_providers` variables have been replaced by new variables - see below for more details

## Additional changes

### Added

- Support for `aws_ecs_capacity_provider` has been added to the module

### Modified

- The `container_insights` variable has been replaced with the `cluster_settings` variable which allows users to enable/disable container insights and also allows for not specifying at all for regions where container insights is currently not supported.
- The `capacity_providers` variable has been replaced with `fargate_capacity_providers`and `autoscaling_capacity_providers`. This allows users to specify either Fargate based capacity providers, EC2 AutoScaling Group capacity providers, or both.
- Previously `capacity_providers` and `default_capacity_provider_strategy` usage looked like:
```hcl
    capacity_providers = ["FARGATE", "FARGATE_SPOT"]

    default_capacity_provider_strategy = [{
        capacity_provider = "FARGATE"
        weight            = 50
        base              = 20
        }, {
        capacity_provider = "FARGATE_SPOT"
        weight            = 50
    }]
```
Where the current equivalent now looks like:
```hcl
    fargate_capacity_providers = {
        "FARGATE" = {
            default_capacity_provider_strategy = {
                weight = 50
                base   = 20
            }
        }
        "FARGATE_SPOT" = {
            default_capacity_provider_strategy = {
                weight = 50
            }
        }
    }
```
- Previously `capacity_providers` accepted the name of an AutoScaling Group created externally; this is now replaced by the usage of `autoscaling_capacity_providers` which incorporates the usage of the newly added support for `aws_ecs_capacity_provider`

### Removed

- `ecs-instance-profile` sub-module has been removed; this functionality is available through the [`terraform-aws-modules/terraform-aws-autoscaling`](https://github.com/terraform-aws-modules/terraform-aws-autoscaling) module starting with version [v6.5.0](https://github.com/terraform-aws-modules/terraform-aws-autoscaling/pull/194). Please see the [`examples/ec2`](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/ec2) example for a demonstration on how to use and integrate with the `terraform-aws-autoscaling` module.

### Variable and output changes

1. Removed variables:

    - `default_capacity_provider_strategy` is now incorporated into the `fargate_capacity_providers` and `autoscaling_capacity_providers` variables.

2. Renamed variables:

    - `create_ecs` -> `create`
    - `name` -> `cluster_name`

3. Added variables:

    - `cluster_configuration` has been added under a dynamic block with all current attributes supported

4. Removed outputs:

    - `ecs_cluster_name`

5. Renamed outputs:

    - `ecs_cluster_id` -> `cluster_id`
    - `ecs_cluster_arn` -> `cluster_arn`

6. Added outputs:

    - `cluster_capacity_providers`
    - `autoscaling_capacity_providers`

## Upgrade Migrations

### Before v3.x Example

```hcl
provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-1"
  name   = "ecs-ex-${replace(basename(path.cwd), "_", "-")}"

  user_data = <<-EOT
    #!/bin/bash
    cat <<'EOF' >> /etc/ecs/ecs.config
    ECS_CLUSTER=${local.name}
    ECS_LOGLEVEL=debug
    EOF
  EOT

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecs"
  }
}

################################################################################
# ECS Module
################################################################################

module "ecs" {
  source = "../../"

  name               = local.name
  container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.prov1.name]

  default_capacity_provider_strategy = [{
    capacity_provider = aws_ecs_capacity_provider.prov1.name # "FARGATE_SPOT"
    weight            = "1"
  }]

  tags = local.tags
}

module "ec2_profile" {
  source = "../../modules/ecs-instance-profile"

  name = local.name

  tags = local.tags
}

resource "aws_ecs_capacity_provider" "prov1" {
  name = "prov1"

  auto_scaling_group_provider {
    auto_scaling_group_arn = module.autoscaling.autoscaling_group_arn
  }
}

################################################################################
# Supporting Resources
################################################################################

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html#ecs-optimized-ami-linux
data "aws_ssm_parameter" "ecs_optimised_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"

  name = local.name

  image_id          = jsondecode(data.aws_ssm_parameter.ecs_optimised_ami.value)["image_id"]
  instance_type     = "t3.micro"
  ebs_optimized     = true
  enable_monitoring = true

  security_groups                 = [module.autoscaling_sg.security_group_id]
  user_data                       = base64encode(local.user_data)
  ignore_desired_capacity_changes = true

  iam_instance_profile_arn = module.ec2_profile.iam_instance_profile_arn

  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = "EC2"
  min_size            = 0
  max_size            = 2
  desired_capacity    = 1

  # https://github.com/hashicorp/terraform-provider-aws/issues/12582
  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  tags = local.tags
}

module "autoscaling_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Autoscaling group security group"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp"]

  egress_rules = ["all-all"]

  tags = local.tags
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.99.0.0/18"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets  = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]

  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  map_public_ip_on_launch = false

  tags = local.tags
}
```

### After v4.x Example

```hcl
provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-1"
  name   = "ecs-ex-${replace(basename(path.cwd), "_", "-")}"

  user_data = <<-EOT
    #!/bin/bash
    cat <<'EOF' >> /etc/ecs/ecs.config
    ECS_CLUSTER=${local.name}
    ECS_LOGLEVEL=debug
    EOF
  EOT

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecs"
  }
}

################################################################################
# ECS Module
################################################################################

module "ecs" {
  # source = "../../"
  source = "../../../terraform-aws-ecs"

  cluster_name = local.name

  fargate_capacity_providers = {
    "FARGATE"      = {}
    "FARGATE_SPOT" = {}
  }

  autoscaling_capacity_providers = {
    prov1 = {
      auto_scaling_group_arn = module.autoscaling.autoscaling_group_arn
      default_capacity_provider_strategy = {
        weight = 1
      }
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html#ecs-optimized-ami-linux
data "aws_ssm_parameter" "ecs_optimised_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"

  name = local.name

  image_id          = jsondecode(data.aws_ssm_parameter.ecs_optimised_ami.value)["image_id"]
  instance_type     = "t3.micro"
  ebs_optimized     = true
  enable_monitoring = true

  security_groups                 = [module.autoscaling_sg.security_group_id]
  user_data                       = base64encode(local.user_data)
  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = local.name
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    CloudWatchLogsFullAccess            = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  }

  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = "EC2"
  min_size            = 0
  max_size            = 2
  desired_capacity    = 1

  # https://github.com/hashicorp/terraform-provider-aws/issues/12582
  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  tags = local.tags
}

module "autoscaling_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Autoscaling group security group"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp"]

  egress_rules = ["all-all"]

  tags = local.tags
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.99.0.0/18"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets  = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]

  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  map_public_ip_on_launch = false

  tags = local.tags
}
```

### Diff of Before vs After

```diff
- module "ec2_profile" {
-   source  = "terraform-aws-modules/ecs/aws/modules/ecs-instance-profile"
-
-   name = local.name
- }

- resource "aws_ecs_capacity_provider" "prov1" {
-   name = "prov1"
-
-   auto_scaling_group_provider {
-     auto_scaling_group_arn = module.autoscaling.autoscaling_group_arn
-   }
- }

 module "ecs" {
   source  = "terraform-aws-modules/ecs/aws"
-  version = "~> 3.0"
+  version = "~> 4.0"

-  name         = local.name
+  cluster_name = local.name

-  container_insights = true
+  # On by default now

-  capacity_providers = ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.prov1.name]
-  default_capacity_provider_strategy = [{
-    capacity_provider = aws_ecs_capacity_provider.prov1.name
-    weight            = "1"
- }]

+  fargate_capacity_providers = {
+    "FARGATE"      = {}
+    "FARGATE_SPOT" = {}
+  }

+  autoscaling_capacity_providers = {
+    prov1 = {
+      auto_scaling_group_arn = module.autoscaling.autoscaling_group_arn
+      default_capacity_provider_strategy = {
+        weight = 1
+      }
+    }
+  }
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"

-  iam_instance_profile_arn = module.ec2_profile.iam_instance_profile_arn

+  create_iam_instance_profile = true
+  iam_role_name               = local.name
+  iam_role_policies = {
+    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
+    CloudWatchLogsFullAccess            = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
+  }
}
```

### State Move Commands

The `terraform state mv ...` commands assocaited with the before and after changes shown above are as follows:

```sh
# Cluster
terraform state mv 'aws_ecs_capacity_provider.prov1' 'module.ecs.aws_ecs_capacity_provider.this["prov1"]'

# IAM instance profile
terraform state mv 'module.ec2_profile.aws_iam_role.this' 'module.autoscaling.aws_iam_role.this[0]'
terraform state mv 'module.ec2_profile.aws_iam_instance_profile.this' 'module.autoscaling.aws_iam_instance_profile.this[0]'
terraform state mv 'module.ec2_profile.aws_iam_role_policy_attachment.ecs_ec2_cloudwatch_role' 'module.autoscaling.aws_iam_role_policy_attachment.this["CloudWatchLogsFullAccess"]'
terraform state mv 'module.ec2_profile.aws_iam_role_policy_attachment.ecs_ec2_role' 'module.autoscaling.aws_iam_role_policy_attachment.this["AmazonEC2ContainerServiceforEC2Role"]'
```
