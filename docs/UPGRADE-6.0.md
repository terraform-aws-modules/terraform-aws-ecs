# Upgrade from v5.x to v6.x

If you have any questions regarding this upgrade process, please consult the [`examples`](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples) directory:
If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Terraform v1.5.7 is now minimum supported version
- AWS provider v6.0.0 is now minimum supported version

## Additional changes

### Added

- Support for `region` parameter to specify the AWS region for the resources created if different from the provider region.

### Modified

- Variable definitions now contain detailed `object` types in place of the previously used any type.

### Variable and output changes

1. Removed variables:

    -

2. Renamed variables:

    -

3. Added variables:

    -

4. Removed outputs:

    -

5. Renamed outputs:

    -

6. Added outputs:

    -

## Upgrade Migrations

### Before 5.x Example

```hcl
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.0"

  # Truncated for brevity ...

  # Container definition(s)
  container_definitions = {

    fluent-bit = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "public.ecr.aws/aws-observability/aws-for-fluent-bit:stable"
      firelens_configuration = {
        type = "fluentbit"
      }
      memory_reservation = 50
      user               = "0"
    }

    ecsdemo-frontend = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
      port_mappings = [
        {
          name          = ecsdemo-frontend
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]

      # Example image used requires access to write to root filesystem
      readonly_root_filesystem = false

      dependencies = [{
        containerName = "fluent-bit"
        condition     = "START"
      }]

      enable_cloudwatch_logging = false
      log_configuration = {
        logDriver = "awsfirelens"
        options = {
          Name                    = "firehose"
          region                  = local.region
          delivery_stream         = "my-stream"
          log-driver-buffer-limit = "2097152"
        }
      }

      linux_parameters = {
        capabilities = {
          add = []
          drop = [
            "NET_RAW"
          ]
        }
      }

      # Not required for fluent-bit, just an example
      volumes_from = [{
        sourceContainer = "fluent-bit"
        readOnly        = false
      }]

      memory_reservation = 100
    }
  }

  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = 3000
      description              = "Service port"
      source_security_group_id = module.alb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

### After 6.x Example

#### Service

```hcl
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 6.0"

  # Truncated for brevity ...

  # Container definition(s)
  container_definitions = {

    fluent-bit = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "public.ecr.aws/aws-observability/aws-for-fluent-bit:stable"
      firelensConfiguration = {
        type = "fluentbit"
      }
      memoryReservation = 50
      user              = "0"
    }

    ecsdemo-frontend = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
      portMappings = [
        {
          name          = "ecsdemo-frontend"
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]

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
          Name                    = "firehose"
          region                  = local.region
          delivery_stream         = "my-stream"
          log-driver-buffer-limit = "2097152"
        }
      }

      linuxParameters = {
        capabilities = {
          add = []
          drop = [
            "NET_RAW"
          ]
        }
      }

      restartPolicy = {
        enabled              = true
        ignoredExitCodes     = [1]
        restartAttemptPeriod = 60
      }

      # Not required for fluent-bit, just an example
      volumesFrom = [{
        sourceContainer = "fluent-bit"
        readOnly        = false
      }]

      memoryReservation = 100
    }
  }

  security_group_ingress_rules = {
    alb_3000 = {
      description                  = "Service port"
      from_port                    = 3000
      referenced_security_group_id = module.alb.security_group_id
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}
```

### State Changes

#### Service

```sh
terraform state rm 'module.ecs_service.aws_security_group_rule.this["alb_ingress_3000"]'
terraform state import 'module.ecs_service.aws_vpc_security_group_ingress_rule.this["alb_3000"]' 'sg-xxx'

terraform state rm 'module.ecs_service.aws_security_group_rule.this["egress_all"]'
terraform state import 'module.ecs_service.aws_vpc_security_group_egress_rule.this["all"]' 'sg-xxx'

```

The inline tasks `aws_iam_role_policy` cannot be moved or imported into a standalone `aws_iam_policy`. It must be re-created.
