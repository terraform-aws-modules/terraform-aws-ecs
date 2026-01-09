# Upgrade from v6.x to v7.x

If you have any questions regarding this upgrade process, please consult the [`examples`](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples) directory:
If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Previously the module would infer the capacity providers to use based on those specified in the `default_capacity_provider_strategy` variable as well as any specified in the `autoscaling_capacity_providers` variable. As of v7.0.0, the module will no longer infer the capacity providers that should be associated with the cluster. Instead, users must explicitly specify the desired capacity providers using the new `cluster_capacity_providers` variable. The only inference of capacity providers are those created by the module itself when using the `capacity_providers` variable. Essentially, if you are using `FARGATE`, `FARGATE_SPOT`, or an externally created capacity provider, you must now specify those in the `cluster_capacity_providers` variable.
- With the addition of ECS managed instances support, the prior variable `autoscaling_capacity_providers` has been replaced with the more generic `capacity_providers` variable. If you were previously using `autoscaling_capacity_providers`, you will need to migrate to the new `capacity_providers` variable by simply renaming it and nesting each ASG capacity provider definition under the argument `auto_scaling_group_provider`. See the before vs after section below for an example of this change. Note: your existing ASG capacity providers will continue to work as before, this is simply a variable rename and variable definition modification. No resources will be replaced/destroyed as part of this change.
- The ECS service variable `ordered_placement_strategy` type definition has been changed from `map(object({...}))` to `list(object({...}))`. The argument needs to preserve order so a list is necessary.

## Additional changes

### Added

- Default name postfixes for IAM roles and security groups have been added, along with default descriptions. When using the intended behavior of simply setting a `var.name` value and relying on the module, these new defaults help to distinguish resources created by the module. Instead of seeing 4 IAM roles named `"example-<random>"`, you will now see names like `"example-service-<random>"`, `"example-task-exec-<random>"`, `"example-tasks-<random>"`, and `"example-infra-<random>"`. To aid in the migration, a variable `disable_v7_default_name_description` has been added that allow users to opt out of theses default settings for existing resources (avoid re-creating them). This ensures an easier upgrade path while also letting new resources benefit from the improved naming and descriptions. Note: this variable and therefore its behavior will be removed in version `v8.0` of the module, giving users time to remediate.
- Support for ECS managed instances has been added. Users can now create an ECS cluster that use EC2 instances created and managed by ECS managed instances capacity provider. Support for this includes the necessary IAM roles as well as a security group that is utilized by the managed instances.

### Modified

- The ECS service infrastructure IAM role is now associated with the `lifecycle_hook` and `advanced_configuration` arguments as part of the progressive deployment options. Users can still provide their own role, but the default now matches the rest of the module where the infrastructure IAM role created by the module will be used unless a different IAM role is provided.

### Variable and output changes

> [!NOTE]
> The variables and outputs added for ECS managed instance support has not been added to this list. Those details are not relevant to the upgrade process. See the [pull request](https://github.com/terraform-aws-modules/terraform-aws-ecs/pull/364) for more details on what has been added for ECS managed instances support (or consult the documentation/examples within the repository).

1. Removed variables:

    - None

2. Renamed variables:

    - `autoscaling_capacity_providers` -> `capacity_providers`

3. Added variables:

    - `cluster_capacity_providers`
    - `disable_v7_default_name_description`

4. Removed outputs:

    - None

5. Renamed outputs:

    - `autoscaling_capacity_providers` -> `capacity_providers`

6. Added outputs:

    - None

## Upgrade Migrations

### Before 6.x Example

#### Root Module

```hcl
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 6.0"

  # Truncated for brevity ...

  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 20
    }
    FARGATE_SPOT = {
      weight = 50
    }
  }

  autoscaling_capacity_providers = {
    ASG = {
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
```

#### Cluster Sub-Module

```hcl
module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 6.0"

  # Truncated for brevity ...

  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 20
    }
    FARGATE_SPOT = {
      weight = 50
    }
  }

  autoscaling_capacity_providers = {
    ASG = {
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
```

### After 7.x Example

#### Root Module

```hcl
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 7.0"

  # Truncated for brevity ...

  cluster_capacity_providers = ["FARGATE", "FARGATE_SPOT"] # <=== add
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 20
    }
    FARGATE_SPOT = {
      weight = 50
    }
  }

  capacity_providers = { # <=== change name
    ASG = {
      auto_scaling_group_provider = { # <=== add
        auto_scaling_group_arn         = module.autoscaling.autoscaling_group_arn
        managed_draining               = "ENABLED"
        managed_termination_protection = "ENABLED"

        managed_scaling = {
          maximum_scaling_step_size = 5
          minimum_scaling_step_size = 1
          status                    = "ENABLED"
          target_capacity           = 60
        }
      } # <=== add
    }
  }
}
```

#### Cluster Sub-Module

```hcl
module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 7.0"

  # Truncated for brevity ...

  cluster_capacity_providers = ["FARGATE", "FARGATE_SPOT"] # <=== add
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 20
    }
    FARGATE_SPOT = {
      weight = 50
    }
  }

  capacity_providers = { # <=== change name
    ASG = {
      auto_scaling_group_provider = { # <=== add
        auto_scaling_group_arn         = module.autoscaling.autoscaling_group_arn
        managed_draining               = "ENABLED"
        managed_termination_protection = "ENABLED"

        managed_scaling = {
          maximum_scaling_step_size = 5
          minimum_scaling_step_size = 1
          status                    = "ENABLED"
          target_capacity           = 60
        }
      } # <=== add
    }
  }
}
```

### State Changes

None required.
