# Upgrade from v5.x to v6.x

If you have any questions regarding this upgrade process, please consult the [`examples`](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples) directory:
If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Terraform `v1.5.7` is now minimum supported version
- AWS provider `v6.0.0` is now minimum supported version
- The attributes used to construct the container definition(s) have been changed from HCL's norm of `snake_case` to `camelCase` to match the AWS API. There currently isn't a [resource nor data source for the container definition](https://github.com/hashicorp/terraform-provider-aws/issues/17988), so one is constructed entirely from HCL in the `container-definition` sub-module. This definition is then rendered as JSON when presented to the task definition (or task set) APIs. Previously, the variable names used were `snake_case` and then internally converted to `camelCase`. However, this does not allow for [using the `container-definition` sub-module on its own](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/147) due to the mismatch between casing. Its probably going to trip a few folks up, but hopefully we'll remove this for a data source in the future.
- `security_group_rules` has been split into `security_group_ingress_rules` and `security_group_egress_rules` to better match the AWS API and allow for more flexibility in defining security group rules.
- Default permissive permissions for SSM parameter ARNs and Secrets Manager secret ARNs have been removed throughout. While this made it easier for users since it "just worked", it was not secure and could lead to unexpected access to resources. Users should now explicitly define the permissions they need in their IAM policies.
- The "hack" put in place to track the task definition version when updating outside of the module has been removed. Instead, users should rely on the `track_latest` variable to ensure that the latest task definition is used when updating the service. Any issues with tracking the task definition version should be reported to the *ECS service team* as it is a limitation of the AWS ECS service/API and not the module itself.
- The inline policy for the Tasks role of the `service` sub-module has been replaced with a standalone IAM policy. In some organizations, inline policies are not allowed.
- The default for the `container-definition` `user` has been changed from `0` to `null`.
- The `container_definition_defaults` variable has been removed along with its functionality. This pattern no longer works with variable optional attributes.

## Additional changes

### Added

- Support for `region` parameter to specify the AWS region for the resources created if different from the provider region.
- Support for ECS infrastructure IAM role creation in the `service` sub-module. This role is used to manage ECS infrastructure resources https://docs.aws.amazon.com/AmazonECS/latest/developerguide/infrastructure_IAM_role.html

### Modified

- Variable definitions now contain detailed `object` types in place of the previously used any type.

### Variable and output changes

1. Removed variables:

    - `default_capacity_provider_use_fargate`
    - `fargate_capacity_providers`
    - `container_definition_defaults`

    - `cluster` sub-module
      - `fargate_capacity_providers`; part of `default_capacity_provider_strategy` now
      - `default_capacity_provider_use_fargate`

    - `container-definition` sub-module
      - None

    - `service` sub-module
      - `inference_accelerator`


2. Renamed variables:

    - `cluster_settings` -> `cluster_setting`

    - `cluster` sub-module
      - `cluster_configuration` - `configuration`
      - `cluster_settings` - `setting`
      - `cluster_service_connect_defaults` - `service_connect_defaults`

    - `container-definition` sub-module
      - `dependencies` - `dependsOn`
      - `disable_networking` - `disableNetworking`
      - `dns_search_domains` - `dnsSearchDomains`
      - `dns_servers` - `dnsServers`
      - `docker_labels` - `dockerLabels`
      - `docker_security_options` - `dockerSecurityOptions`
      - `environment_files` - `environmentFiles`
      - `extra_hosts` - `extraHosts`
      - `firelens_configuration` - `firelensConfiguration`
      - `health_check` - `healthCheck`
      - `linux_parameters` - `linuxParameters`
      - `log_configuration` - `logConfiguration`
      - `memory_reservation` - `memoryReservation`
      - `mount_points` - `mountPoints`
      - `port_mappings` - `portMappings`
      - `psuedo_terminal` - `pseudoTerminal`
      - `readonly_root_filesystem` - `readonlyRootFilesystem`
      - `repository_credentials` - `repositoryCredentials`
      - `start_timeout` - `startTimeout`
      - `system_controls` - `systemControls`
      - `volumes_from` - `volumesFrom`
      - `working_directory` - `workingDirectory`

    - `service` sub-module
      - None

3. Added variables:

    - `cloudwatch_log_group_class`
    - `default_capacity_provider_strategy`

    - `cluster` sub-module
      - `cloudwatch_log_group_class`
      - `default_capacity_provider_strategy` - replaces `fargate_capacity_providers` and `default_capacity_provider_use_fargate` functionality

    - `container-definition` sub-module
      - `log_group_class`
      - `restartPolicy` - defaults to `enabled = true`
      - `versionConsistency` - defaults to `"disabled"` https://github.com/aws/containers-roadmap/issues/2394

    - `service` sub-module
      - `availability_zone_rebalancing`
      - `volume_configuration`
      - `vpc_lattice_configurations`
      - `enable_fault_injection`
      - `track_latest`
      - `create_infrastructure_iam_role`
      - `infrastructure_iam_role_arn`
      - `infrastructure_iam_role_name`
      - `infrastructure_iam_role_use_name_prefix`
      - `infrastructure_iam_role_path`
      - `infrastructure_iam_role_description`
      - `infrastructure_iam_role_permissions_boundary`
      - `infrastructure_iam_role_tags`

4. Removed outputs:

    - `cluster` sub-module
      - None
    - `container-definition` sub-module
      - None
    - `service` sub-module
      - `task_definition_family_revision`

5. Renamed outputs:

    - `cluster` sub-module
      - None
    - `container-definition` sub-module
      - None
    - `service` sub-module
      - None

6. Added outputs:

    - `cluster` sub-module
      - None
    - `container-definition` sub-module
      - None
    - `service` sub-module
      - `infrastructure_iam_role_arn`
      - `infrastructure_iam_role_name`

## Upgrade Migrations

### Before 5.x Example

#### Cluster Sub-Module

```hcl
module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 5.0"

  # Truncated for brevity ...

  # Capacity provider
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
}
```

#### Service Sub-Module

```hcl
module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
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

  service_connect_configuration = {
    namespace = aws_service_discovery_http_namespace.this.arn
    service = {
      client_alias = {
        port     = 3000
        dns_name = "ecsdemo-frontend"
      }
      port_name      = "ecsdemo-frontend"
      discovery_name = "ecsdemo-frontend"
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

#### Cluster Sub-Module

```hcl
module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 6.0"

  # Truncated for brevity ...

  # Cluster capacity providers
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 20
    }
    FARGATE_SPOT = {
      weight = 50
    }
  }
}
```

#### Service Sub-Module

```hcl
module "ecs_service" {
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

  service_connect_configuration = {
    namespace = aws_service_discovery_http_namespace.this.arn
    service = [
      {
        client_alias = {
          port     = 3000
          dns_name = "ecsdemo-frontend"
        }
        port_name      = "ecsdemo-frontend"
        discovery_name = "ecsdemo-frontend"
      }
    ]
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

#### Service Sub-Module

Due to the change from `aws_security_group_rule` to `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule`, the following reference state changes are required to maintain the current security group rules. (Note: these are different resources so they cannot be moved with `terraform mv ...`)

```sh
terraform state rm 'module.ecs_service.aws_security_group_rule.this["alb_ingress_3000"]'
terraform state import 'module.ecs_service.aws_vpc_security_group_ingress_rule.this["alb_3000"]' 'sg-xxx'

terraform state rm 'module.ecs_service.aws_security_group_rule.this["egress_all"]'
terraform state import 'module.ecs_service.aws_vpc_security_group_egress_rule.this["all"]' 'sg-xxx'
```

The inline tasks `aws_iam_role_policy` cannot be moved or imported into a standalone `aws_iam_policy`. It must be re-created.
