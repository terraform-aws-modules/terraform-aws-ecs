# Upgrade from v3.x to v4.x

Please consult the `examples` directory for reference example configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Minimum supported version of Terraform AWS provider updated to v4.6 to support the latest resources utilized
- Minimum supported version of Terraform updated to v1.0
- `ecs-instance-profile` sub-module has been removed; this functionality is available through the [`terraform-aws-modules/terraform-aws-autoscaling`](https://github.com/terraform-aws-modules/terraform-aws-autoscaling) module starting with version [v6.5.0](https://github.com/terraform-aws-modules/terraform-aws-autoscaling/pull/194). Please see the [`examples/complete`](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/complete) example for a demonstration on how to use and integrate with the `terraform-aws-autoscaling` module.
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
        FARGATE = {
            default_capacity_provider_strategy = {
                weight = 50
                base   = 20
            }
        }
        FARGATE_SPOT = {
            default_capacity_provider_strategy = {
                weight = 50
            }
        }
    }
```
- Previously `capacity_providers` accepted the name of an AutoScaling Group created externally; this is now replaced by the usage of `autoscaling_capacity_providers` which incorporates the usage of the newly added support for `aws_ecs_capacity_provider`

### Removed

- `ecs-instance-profile` sub-module has been removed; this functionality is available through the [`terraform-aws-modules/terraform-aws-autoscaling`](https://github.com/terraform-aws-modules/terraform-aws-autoscaling) module starting with version [v6.5.0](https://github.com/terraform-aws-modules/terraform-aws-autoscaling/pull/194). Please see the [`examples/complete`](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/complete) example for a demonstration on how to use and integrate with the `terraform-aws-autoscaling` module.

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
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "3.5.0"

  name               = "example"
  container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.prov1.name]

  default_capacity_provider_strategy = [{
    capacity_provider = aws_ecs_capacity_provider.prov1.name
    weight            = "1"
  }]
}

module "ec2_profile" {
  source  = "terraform-aws-modules/ecs/aws//modules/ecs-instance-profile"
  version = "3.5.0"

  name = local.name
}

resource "aws_ecs_capacity_provider" "prov1" {
  name = "prov1"

  auto_scaling_group_provider {
    auto_scaling_group_arn = module.autoscaling.autoscaling_group_arn
  }
}
```

### After v4.x Example

```hcl
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.0.0"

  cluster_name = "example"

  fargate_capacity_providers = {
    FARGATE      = {}
    FARGATE_SPOT = {}
  }

  autoscaling_capacity_providers = {
    prov1 = {
      auto_scaling_group_arn = module.autoscaling.autoscaling_group_arn
      default_capacity_provider_strategy = {
        weight = 1
      }
    }
  }
}

module "ec2_profile" {
  source  = "terraform-aws-modules/ecs/aws//modules/ecs-instance-profile"
  # Users can pin and stay on v3.5.0 until they able to use the IAM instance
  # profile provided through the autoscaling group module
  version = "3.5.0"

  name = "example
}
```

### Diff of Before vs After

```diff
- resource "aws_ecs_capacity_provider" "prov1" {
-   name = "prov1"
-
-   auto_scaling_group_provider {
-     auto_scaling_group_arn = module.autoscaling.autoscaling_group_arn
-   }
- }

 module "ecs" {
   source  = "terraform-aws-modules/ecs/aws"
-  version = "3.5.0"
+  version = "4.0.0"

-  name         = "example"
+  cluster_name = "example"

-  container_insights = true
+  # On by default now

-  capacity_providers = ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.prov1.name]
-  default_capacity_provider_strategy = [{
-    capacity_provider = aws_ecs_capacity_provider.prov1.name
-    weight            = "1"
- }]

+  fargate_capacity_providers = {
+    FARGATE      = {}
+    FARGATE_SPOT = {}
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
```

### State Move Commands

In conjunction with the changes above, users can elect to move their external capacity provider(s) under this module using the following move command. Command is shown using the values from the example shown above, please update to suit your configuration names:

```sh
# Cluster
terraform state mv 'aws_ecs_capacity_provider.prov1' 'module.ecs.aws_ecs_capacity_provider.this["prov1"]'
```
