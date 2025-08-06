# AWS ECS Terraform module

Terraform module which creates ECS (Elastic Container Service) resources on AWS.

[![SWUbanner](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md)

## Available Features

- ECS cluster w/ Fargate or EC2 Auto Scaling capacity providers
- ECS Service w/ task definition, task set, and container definition support
- Separate sub-modules or integrated module for ECS cluster and service

For more details see the [design doc](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/docs/README.md)

## Usage

This project supports creating resources through individual sub-modules, or through a single module that creates both the cluster and service resources. See the respective sub-module directory for more details and example usage.

### Integrated Cluster w/ Services

```hcl
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-integrated"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

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

  services = {
    ecsdemo-frontend = {
      cpu    = 1024
      memory = 4096

      # Container definition(s)
      container_definitions = {

        fluent-bit = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "906394416424.dkr.ecr.us-west-2.amazonaws.com/aws-for-fluent-bit:stable"
          firelensConfiguration = {
            type = "fluentbit"
          }
          memoryReservation = 50
        }

        ecs-sample = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
          portMappings = [
            {
              name          = "ecs-sample"
              containerPort = 80
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
              region                  = "eu-west-1"
              delivery_stream         = "my-stream"
              log-driver-buffer-limit = "2097152"
            }
          }
          memoryReservation = 100
        }
      }

      service_connect_configuration = {
        namespace = "example"
        service = {
          client_alias = {
            port     = 80
            dns_name = "ecs-sample"
          }
          port_name      = "ecs-sample"
          discovery_name = "ecs-sample"
        }
      }

      load_balancer = {
        service = {
          target_group_arn = "arn:aws:elasticloadbalancing:eu-west-1:1234567890:targetgroup/bluegreentarget1/209a844cd01825a4"
          container_name   = "ecs-sample"
          container_port   = 80
        }
      }

      subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
      security_group_ingress_rules = {
        alb_3000 = {
          description                  = "Service port"
          from_port                    = local.container_port
          ip_protocol                  = "tcp"
          referenced_security_group_id = "sg-12345678"
        }
      }
      security_group_egress_rules = {
        all = {
          ip_protocol = "-1"
          cidr_ipv4   = "0.0.0.0/0"
        }
      }
    }
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

- [ECS Cluster Complete](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/complete)
- [ECS Cluster w/ EC2 Autoscaling Capacity Provider](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/ec2-autoscaling)
- [ECS Cluster w/ Fargate Capacity Provider](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/fargate)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.4 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster"></a> [cluster](#module\_cluster) | ./modules/cluster | n/a |
| <a name="module_service"></a> [service](#module\_service) | ./modules/service | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaling_capacity_providers"></a> [autoscaling\_capacity\_providers](#input\_autoscaling\_capacity\_providers) | Map of autoscaling capacity provider definitions to create for the cluster | <pre>map(object({<br/>    auto_scaling_group_arn = string<br/>    managed_draining       = optional(string, "ENABLED")<br/>    managed_scaling = optional(object({<br/>      instance_warmup_period    = optional(number)<br/>      maximum_scaling_step_size = optional(number)<br/>      minimum_scaling_step_size = optional(number)<br/>      status                    = optional(string)<br/>      target_capacity           = optional(number)<br/>    }))<br/>    managed_termination_protection = optional(string)<br/>    name                           = optional(string) # Will fall back to use map key if not set<br/>    tags                           = optional(map(string), {})<br/>  }))</pre> | `null` | no |
| <a name="input_cloudwatch_log_group_class"></a> [cloudwatch\_log\_group\_class](#input\_cloudwatch\_log\_group\_class) | Specified the log class of the log group. Possible values are: `STANDARD` or `INFREQUENT_ACCESS` | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch\_log\_group\_kms\_key\_id](#input\_cloudwatch\_log\_group\_kms\_key\_id) | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Custom name of CloudWatch Log Group for ECS cluster | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events | `number` | `90` | no |
| <a name="input_cloudwatch_log_group_tags"></a> [cloudwatch\_log\_group\_tags](#input\_cloudwatch\_log\_group\_tags) | A map of additional tags to add to the log group created | `map(string)` | `{}` | no |
| <a name="input_cluster_configuration"></a> [cluster\_configuration](#input\_cluster\_configuration) | The execute command configuration for the cluster | <pre>object({<br/>    execute_command_configuration = optional(object({<br/>      kms_key_id = optional(string)<br/>      log_configuration = optional(object({<br/>        cloud_watch_encryption_enabled = optional(bool)<br/>        cloud_watch_log_group_name     = optional(string)<br/>        s3_bucket_encryption_enabled   = optional(bool)<br/>        s3_bucket_name                 = optional(string)<br/>        s3_kms_key_id                  = optional(string)<br/>        s3_key_prefix                  = optional(string)<br/>      }))<br/>      logging = optional(string, "OVERRIDE")<br/>    }))<br/>    managed_storage_configuration = optional(object({<br/>      fargate_ephemeral_storage_kms_key_id = optional(string)<br/>      kms_key_id                           = optional(string)<br/>    }))<br/>  })</pre> | <pre>{<br/>  "execute_command_configuration": {<br/>    "log_configuration": {<br/>      "cloud_watch_log_group_name": "placeholder"<br/>    }<br/>  }<br/>}</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster (up to 255 letters, numbers, hyphens, and underscores) | `string` | `""` | no |
| <a name="input_cluster_service_connect_defaults"></a> [cluster\_service\_connect\_defaults](#input\_cluster\_service\_connect\_defaults) | Configures a default Service Connect namespace | <pre>object({<br/>    namespace = string<br/>  })</pre> | `null` | no |
| <a name="input_cluster_setting"></a> [cluster\_setting](#input\_cluster\_setting) | List of configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "name": "containerInsights",<br/>    "value": "enabled"<br/>  }<br/>]</pre> | no |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | A map of additional tags to add to the cluster | `map(string)` | `{}` | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether resources will be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled | `bool` | `true` | no |
| <a name="input_create_task_exec_iam_role"></a> [create\_task\_exec\_iam\_role](#input\_create\_task\_exec\_iam\_role) | Determines whether the ECS task definition IAM role should be created | `bool` | `false` | no |
| <a name="input_create_task_exec_policy"></a> [create\_task\_exec\_policy](#input\_create\_task\_exec\_policy) | Determines whether the ECS task definition IAM policy should be created. This includes permissions included in AmazonECSTaskExecutionRolePolicy as well as access to secrets and SSM parameters | `bool` | `true` | no |
| <a name="input_default_capacity_provider_strategy"></a> [default\_capacity\_provider\_strategy](#input\_default\_capacity\_provider\_strategy) | Map of default capacity provider strategy definitions to use for the cluster | <pre>map(object({<br/>    base   = optional(number)<br/>    name   = optional(string) # Will fall back to use map key if not set<br/>    weight = optional(number)<br/>  }))</pre> | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_services"></a> [services](#input\_services) | Map of service definitions to create | <pre>map(object({<br/>    create         = optional(bool)<br/>    create_service = optional(bool)<br/>    tags           = optional(map(string))<br/><br/>    # Service<br/>    ignore_task_definition_changes = optional(bool)<br/>    alarms = optional(object({<br/>      alarm_names = list(string)<br/>      enable      = optional(bool)<br/>      rollback    = optional(bool)<br/>    }))<br/>    availability_zone_rebalancing = optional(string)<br/>    capacity_provider_strategy = optional(map(object({<br/>      base              = optional(number)<br/>      capacity_provider = string<br/>      weight            = optional(number)<br/>    })))<br/>    deployment_circuit_breaker = optional(object({<br/>      enable   = bool<br/>      rollback = bool<br/>    }))<br/>    deployment_configuration = optional(object({<br/>      strategy             = optional(string)<br/>      bake_time_in_minutes = optional(string)<br/>      lifecycle_hook = optional(map(object({<br/>        hook_target_arn  = string<br/>        role_arn         = string<br/>        lifecycle_stages = list(string)<br/>      })))<br/>    }))<br/>    deployment_controller = optional(object({<br/>      type = optional(string)<br/>    }))<br/>    deployment_maximum_percent         = optional(number, 200)<br/>    deployment_minimum_healthy_percent = optional(number, 66)<br/>    desired_count                      = optional(number, 1)<br/>    enable_ecs_managed_tags            = optional(bool)<br/>    enable_execute_command             = optional(bool)<br/>    force_delete                       = optional(bool)<br/>    force_new_deployment               = optional(bool)<br/>    health_check_grace_period_seconds  = optional(number)<br/>    launch_type                        = optional(string)<br/>    load_balancer = optional(map(object({<br/>      container_name   = string<br/>      container_port   = number<br/>      elb_name         = optional(string)<br/>      target_group_arn = optional(string)<br/>      advanced_configuration = optional(object({<br/>        alternate_target_group_arn = string<br/>        production_listener_rule   = string<br/>        role_arn                   = string<br/>        test_listener_rule         = optional(string)<br/>      }))<br/>    })))<br/>    name               = optional(string) # Will fall back to use map key if not set<br/>    assign_public_ip   = optional(bool)<br/>    security_group_ids = optional(list(string))<br/>    subnet_ids         = optional(list(string))<br/>    ordered_placement_strategy = optional(map(object({<br/>      field = optional(string)<br/>      type  = string<br/>    })))<br/>    placement_constraints = optional(map(object({<br/>      expression = optional(string)<br/>      type       = string<br/>    })))<br/>    platform_version    = optional(string)<br/>    propagate_tags      = optional(string)<br/>    scheduling_strategy = optional(string)<br/>    service_connect_configuration = optional(object({<br/>      enabled = optional(bool)<br/>      log_configuration = optional(object({<br/>        log_driver = string<br/>        options    = optional(map(string))<br/>        secret_option = optional(list(object({<br/>          name       = string<br/>          value_from = string<br/>        })))<br/>      }))<br/>      namespace = optional(string)<br/>      service = optional(list(object({<br/>        client_alias = optional(object({<br/>          dns_name = optional(string)<br/>          port     = number<br/>          test_traffic_rules = optional(list(object({<br/>            header = optional(object({<br/>              name = string<br/>              value = object({<br/>                exact = string<br/>              })<br/>            }))<br/>          })))<br/>        }))<br/>        discovery_name        = optional(string)<br/>        ingress_port_override = optional(number)<br/>        port_name             = string<br/>        timeout = optional(object({<br/>          idle_timeout_seconds        = optional(number)<br/>          per_request_timeout_seconds = optional(number)<br/>        }))<br/>        tls = optional(object({<br/>          issuer_cert_authority = object({<br/>            aws_pca_authority_arn = string<br/>          })<br/>          kms_key  = optional(string)<br/>          role_arn = optional(string)<br/>        }))<br/>      })))<br/>    }))<br/>    service_registries = optional(object({<br/>      container_name = optional(string)<br/>      container_port = optional(number)<br/>      port           = optional(number)<br/>      registry_arn   = string<br/>    }))<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>    triggers = optional(map(string))<br/>    volume_configuration = optional(object({<br/>      name = string<br/>      managed_ebs_volume = object({<br/>        encrypted        = optional(bool)<br/>        file_system_type = optional(string)<br/>        iops             = optional(number)<br/>        kms_key_id       = optional(string)<br/>        size_in_gb       = optional(number)<br/>        snapshot_id      = optional(string)<br/>        tag_specifications = optional(list(object({<br/>          propagate_tags = optional(string)<br/>          resource_type  = string<br/>          tags           = optional(map(string))<br/>        })))<br/>        throughput  = optional(number)<br/>        volume_type = optional(string)<br/>      })<br/>    }))<br/>    vpc_lattice_configurations = optional(object({<br/>      role_arn         = string<br/>      target_group_arn = string<br/>      port_name        = string<br/>    }))<br/>    wait_for_steady_state = optional(bool)<br/>    service_tags          = optional(map(string))<br/>    # Service - IAM Role<br/>    create_iam_role               = optional(bool)<br/>    iam_role_arn                  = optional(string)<br/>    iam_role_name                 = optional(string)<br/>    iam_role_use_name_prefix      = optional(bool)<br/>    iam_role_path                 = optional(string)<br/>    iam_role_description          = optional(string)<br/>    iam_role_permissions_boundary = optional(string)<br/>    iam_role_tags                 = optional(map(string))<br/>    iam_role_statements = optional(list(object({<br/>      sid           = optional(string)<br/>      actions       = optional(list(string))<br/>      not_actions   = optional(list(string))<br/>      effect        = optional(string)<br/>      resources     = optional(list(string))<br/>      not_resources = optional(list(string))<br/>      principals = optional(list(object({<br/>        type        = string<br/>        identifiers = list(string)<br/>      })))<br/>      not_principals = optional(list(object({<br/>        type        = string<br/>        identifiers = list(string)<br/>      })))<br/>      condition = optional(list(object({<br/>        test     = string<br/>        values   = list(string)<br/>        variable = string<br/>      })))<br/>    })))<br/>    # Task Definition<br/>    create_task_definition = optional(bool)<br/>    task_definition_arn    = optional(string)<br/>    container_definitions = optional(map(object({<br/>      operating_system_family = optional(string)<br/>      tags                    = optional(map(string))<br/><br/>      # Container definition<br/>      command = optional(list(string))<br/>      cpu     = optional(number)<br/>      dependsOn = optional(list(object({<br/>        condition     = string<br/>        containerName = string<br/>      })))<br/>      disableNetworking      = optional(bool)<br/>      dnsSearchDomains       = optional(list(string))<br/>      dnsServers             = optional(list(string))<br/>      dockerLabels           = optional(map(string))<br/>      dockerSecurityOptions  = optional(list(string))<br/>      enable_execute_command = optional(bool)<br/>      entrypoint             = optional(list(string))<br/>      environment = optional(list(object({<br/>        name  = string<br/>        value = string<br/>      })))<br/>      environmentFiles = optional(list(object({<br/>        type  = string<br/>        value = string<br/>      })))<br/>      essential = optional(bool)<br/>      extraHosts = optional(list(object({<br/>        hostname  = string<br/>        ipAddress = string<br/>      })))<br/>      firelensConfiguration = optional(object({<br/>        options = optional(map(string))<br/>        type    = optional(string)<br/>      }))<br/>      healthCheck = optional(object({<br/>        command     = optional(list(string))<br/>        interval    = optional(number)<br/>        retries     = optional(number)<br/>        startPeriod = optional(number)<br/>        timeout     = optional(number)<br/>      }))<br/>      hostname    = optional(string)<br/>      image       = optional(string)<br/>      interactive = optional(bool)<br/>      links       = optional(list(string))<br/>      linuxParameters = optional(object({<br/>        capabilities = optional(object({<br/>          add  = optional(list(string))<br/>          drop = optional(list(string))<br/>        }))<br/>        devices = optional(list(object({<br/>          containerPath = optional(string)<br/>          hostPath      = optional(string)<br/>          permissions   = optional(list(string))<br/>        })))<br/>        initProcessEnabled = optional(bool)<br/>        maxSwap            = optional(number)<br/>        sharedMemorySize   = optional(number)<br/>        swappiness         = optional(number)<br/>        tmpfs = optional(list(object({<br/>          containerPath = string<br/>          mountOptions  = optional(list(string))<br/>          size          = number<br/>        })))<br/>      }))<br/>      logConfiguration = optional(object({<br/>        logDriver = optional(string)<br/>        options   = optional(map(string))<br/>        secretOptions = optional(list(object({<br/>          name      = string<br/>          valueFrom = string<br/>        })))<br/>      }))<br/>      memory            = optional(number)<br/>      memoryReservation = optional(number)<br/>      mountPoints = optional(list(object({<br/>        containerPath = optional(string)<br/>        readOnly      = optional(bool)<br/>        sourceVolume  = optional(string)<br/>      })), [])<br/>      name = optional(string)<br/>      portMappings = optional(list(object({<br/>        appProtocol        = optional(string)<br/>        containerPort      = optional(number)<br/>        containerPortRange = optional(string)<br/>        hostPort           = optional(number)<br/>        name               = optional(string)<br/>        protocol           = optional(string)<br/>      })), [])<br/>      privileged             = optional(bool)<br/>      pseudoTerminal         = optional(bool)<br/>      readonlyRootFilesystem = optional(bool)<br/>      repositoryCredentials = optional(object({<br/>        credentialsParameter = optional(string)<br/>      }))<br/>      resourceRequirements = optional(list(object({<br/>        type  = string<br/>        value = string<br/>      })))<br/>      restartPolicy = optional(object({<br/>        enabled              = optional(bool)<br/>        ignoredExitCodes     = optional(list(number))<br/>        restartAttemptPeriod = optional(number)<br/>      }))<br/>      secrets = optional(list(object({<br/>        name      = string<br/>        valueFrom = string<br/>      })))<br/>      startTimeout = optional(number)<br/>      stopTimeout  = optional(number)<br/>      systemControls = optional(list(object({<br/>        namespace = optional(string)<br/>        value     = optional(string)<br/>      })))<br/>      ulimits = optional(list(object({<br/>        hardLimit = number<br/>        name      = string<br/>        softLimit = number<br/>      })))<br/>      user               = optional(string)<br/>      versionConsistency = optional(string)<br/>      volumesFrom = optional(list(object({<br/>        readOnly        = optional(bool)<br/>        sourceContainer = optional(string)<br/>      })))<br/>      workingDirectory = optional(string)<br/><br/>      # Cloudwatch Log Group<br/>      service                                = optional(string, "")<br/>      enable_cloudwatch_logging              = optional(bool)<br/>      create_cloudwatch_log_group            = optional(bool)<br/>      cloudwatch_log_group_name              = optional(string)<br/>      cloudwatch_log_group_use_name_prefix   = optional(bool)<br/>      cloudwatch_log_group_class             = optional(string)<br/>      cloudwatch_log_group_retention_in_days = optional(number)<br/>      cloudwatch_log_group_kms_key_id        = optional(string)<br/>    })))<br/>    cpu                    = optional(number, 1024)<br/>    enable_fault_injection = optional(bool)<br/>    ephemeral_storage = optional(object({<br/>      size_in_gib = number<br/>    }))<br/>    family       = optional(string)<br/>    ipc_mode     = optional(string)<br/>    memory       = optional(number, 2048)<br/>    network_mode = optional(string)<br/>    pid_mode     = optional(string)<br/>    proxy_configuration = optional(object({<br/>      container_name = string<br/>      properties     = optional(map(string))<br/>      type           = optional(string)<br/>    }))<br/>    requires_compatibilities = optional(list(string))<br/>    runtime_platform = optional(object({<br/>      cpu_architecture        = optional(string)<br/>      operating_system_family = optional(string)<br/>    }))<br/>    skip_destroy = optional(bool)<br/>    task_definition_placement_constraints = optional(map(object({<br/>      expression = optional(string)<br/>      type       = string<br/>    })))<br/>    track_latest = optional(bool)<br/>    volume = optional(map(object({<br/>      configure_at_launch = optional(bool)<br/>      docker_volume_configuration = optional(object({<br/>        autoprovision = optional(bool)<br/>        driver        = optional(string)<br/>        driver_opts   = optional(map(string))<br/>        labels        = optional(map(string))<br/>        scope         = optional(string)<br/>      }))<br/>      efs_volume_configuration = optional(object({<br/>        authorization_config = optional(object({<br/>          access_point_id = optional(string)<br/>          iam             = optional(string)<br/>        }))<br/>        file_system_id          = string<br/>        root_directory          = optional(string)<br/>        transit_encryption      = optional(string)<br/>        transit_encryption_port = optional(number)<br/>      }))<br/>      fsx_windows_file_server_volume_configuration = optional(object({<br/>        authorization_config = optional(object({<br/>          credentials_parameter = string<br/>          domain                = string<br/>        }))<br/>        file_system_id = string<br/>        root_directory = string<br/>      }))<br/>      host_path = optional(string)<br/>      name      = optional(string)<br/>    })))<br/>    task_tags = optional(map(string))<br/>    # Task Execution - IAM Role<br/>    create_task_exec_iam_role               = optional(bool)<br/>    task_exec_iam_role_arn                  = optional(string)<br/>    task_exec_iam_role_name                 = optional(string)<br/>    task_exec_iam_role_use_name_prefix      = optional(bool)<br/>    task_exec_iam_role_path                 = optional(string)<br/>    task_exec_iam_role_description          = optional(string)<br/>    task_exec_iam_role_permissions_boundary = optional(string)<br/>    task_exec_iam_role_tags                 = optional(map(string))<br/>    task_exec_iam_role_policies             = optional(map(string))<br/>    task_exec_iam_role_max_session_duration = optional(number)<br/>    create_task_exec_policy                 = optional(bool)<br/>    task_exec_ssm_param_arns                = optional(list(string))<br/>    task_exec_secret_arns                   = optional(list(string))<br/>    task_exec_iam_statements = optional(list(object({<br/>      sid           = optional(string)<br/>      actions       = optional(list(string))<br/>      not_actions   = optional(list(string))<br/>      effect        = optional(string)<br/>      resources     = optional(list(string))<br/>      not_resources = optional(list(string))<br/>      principals = optional(list(object({<br/>        type        = string<br/>        identifiers = list(string)<br/>      })))<br/>      not_principals = optional(list(object({<br/>        type        = string<br/>        identifiers = list(string)<br/>      })))<br/>      condition = optional(list(object({<br/>        test     = string<br/>        values   = list(string)<br/>        variable = string<br/>      })))<br/>    })))<br/>    task_exec_iam_policy_path = optional(string)<br/>    # Tasks - IAM Role<br/>    create_tasks_iam_role               = optional(bool)<br/>    tasks_iam_role_arn                  = optional(string)<br/>    tasks_iam_role_name                 = optional(string)<br/>    tasks_iam_role_use_name_prefix      = optional(bool)<br/>    tasks_iam_role_path                 = optional(string)<br/>    tasks_iam_role_description          = optional(string)<br/>    tasks_iam_role_permissions_boundary = optional(string)<br/>    tasks_iam_role_tags                 = optional(map(string))<br/>    tasks_iam_role_policies             = optional(map(string))<br/>    tasks_iam_role_statements = optional(list(object({<br/>      sid           = optional(string)<br/>      actions       = optional(list(string))<br/>      not_actions   = optional(list(string))<br/>      effect        = optional(string)<br/>      resources     = optional(list(string))<br/>      not_resources = optional(list(string))<br/>      principals = optional(list(object({<br/>        type        = string<br/>        identifiers = list(string)<br/>      })))<br/>      not_principals = optional(list(object({<br/>        type        = string<br/>        identifiers = list(string)<br/>      })))<br/>      condition = optional(list(object({<br/>        test     = string<br/>        values   = list(string)<br/>        variable = string<br/>      })))<br/>    })))<br/>    # Task Set<br/>    external_id = optional(string)<br/>    scale = optional(object({<br/>      unit  = optional(string)<br/>      value = optional(number)<br/>    }))<br/>    wait_until_stable         = optional(bool)<br/>    wait_until_stable_timeout = optional(string)<br/>    # Autoscaling<br/>    enable_autoscaling       = optional(bool)<br/>    autoscaling_min_capacity = optional(number)<br/>    autoscaling_max_capacity = optional(number)<br/>    autoscaling_policies = optional(map(object({<br/>      name        = optional(string) # Will fall back to the key name if not provided<br/>      policy_type = optional(string)<br/>      step_scaling_policy_configuration = optional(object({<br/>        adjustment_type          = optional(string)<br/>        cooldown                 = optional(number)<br/>        metric_aggregation_type  = optional(string)<br/>        min_adjustment_magnitude = optional(number)<br/>        step_adjustment = optional(list(object({<br/>          metric_interval_lower_bound = optional(string)<br/>          metric_interval_upper_bound = optional(string)<br/>          scaling_adjustment          = number<br/>        })))<br/>      }))<br/>      target_tracking_scaling_policy_configuration = optional(object({<br/>        customized_metric_specification = optional(object({<br/>          dimensions = optional(list(object({<br/>            name  = string<br/>            value = string<br/>          })))<br/>          metric_name = optional(string)<br/>          metrics = optional(list(object({<br/>            expression = optional(string)<br/>            id         = string<br/>            label      = optional(string)<br/>            metric_stat = optional(object({<br/>              metric = object({<br/>                dimensions = optional(list(object({<br/>                  name  = string<br/>                  value = string<br/>                })))<br/>                metric_name = string<br/>                namespace   = string<br/>              })<br/>              stat = string<br/>              unit = optional(string)<br/>            }))<br/>            return_data = optional(bool)<br/>          })))<br/>          namespace = optional(string)<br/>          statistic = optional(string)<br/>          unit      = optional(string)<br/>        }))<br/><br/>        disable_scale_in = optional(bool)<br/>        predefined_metric_specification = optional(object({<br/>          predefined_metric_type = string<br/>          resource_label         = optional(string)<br/>        }))<br/>        scale_in_cooldown  = optional(number)<br/>        scale_out_cooldown = optional(number)<br/>        target_value       = optional(number)<br/>      }))<br/>    })))<br/>    autoscaling_scheduled_actions = optional(map(object({<br/>      name         = optional(string)<br/>      min_capacity = number<br/>      max_capacity = number<br/>      schedule     = string<br/>      start_time   = optional(string)<br/>      end_time     = optional(string)<br/>      timezone     = optional(string)<br/>    })))<br/>    # Security Group<br/>    create_security_group          = optional(bool)<br/>    security_group_name            = optional(string)<br/>    security_group_use_name_prefix = optional(bool)<br/>    security_group_description     = optional(string)<br/>    security_group_ingress_rules = optional(map(object({<br/>      cidr_ipv4                    = optional(string)<br/>      cidr_ipv6                    = optional(string)<br/>      description                  = optional(string)<br/>      from_port                    = optional(string)<br/>      ip_protocol                  = optional(string)<br/>      prefix_list_id               = optional(string)<br/>      referenced_security_group_id = optional(string)<br/>      tags                         = optional(map(string))<br/>      to_port                      = optional(string)<br/>    })))<br/>    security_group_egress_rules = optional(map(object({<br/>      cidr_ipv4                    = optional(string)<br/>      cidr_ipv6                    = optional(string)<br/>      description                  = optional(string)<br/>      from_port                    = optional(string)<br/>      ip_protocol                  = optional(string)<br/>      prefix_list_id               = optional(string)<br/>      referenced_security_group_id = optional(string)<br/>      tags                         = optional(map(string))<br/>      to_port                      = optional(string)<br/>    })))<br/>    security_group_tags = optional(map(string))<br/>    # ECS Infrastructure IAM Role<br/>    create_infrastructure_iam_role               = optional(bool)<br/>    infrastructure_iam_role_arn                  = optional(string)<br/>    infrastructure_iam_role_name                 = optional(string)<br/>    infrastructure_iam_role_use_name_prefix      = optional(bool)<br/>    infrastructure_iam_role_path                 = optional(string)<br/>    infrastructure_iam_role_description          = optional(string)<br/>    infrastructure_iam_role_permissions_boundary = optional(string)<br/>    infrastructure_iam_role_tags                 = optional(map(string))<br/>  }))</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_task_exec_iam_role_description"></a> [task\_exec\_iam\_role\_description](#input\_task\_exec\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_task_exec_iam_role_name"></a> [task\_exec\_iam\_role\_name](#input\_task\_exec\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_task_exec_iam_role_path"></a> [task\_exec\_iam\_role\_path](#input\_task\_exec\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_task_exec_iam_role_permissions_boundary"></a> [task\_exec\_iam\_role\_permissions\_boundary](#input\_task\_exec\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_task_exec_iam_role_policies"></a> [task\_exec\_iam\_role\_policies](#input\_task\_exec\_iam\_role\_policies) | Map of IAM role policy ARNs to attach to the IAM role | `map(string)` | `{}` | no |
| <a name="input_task_exec_iam_role_tags"></a> [task\_exec\_iam\_role\_tags](#input\_task\_exec\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_task_exec_iam_role_use_name_prefix"></a> [task\_exec\_iam\_role\_use\_name\_prefix](#input\_task\_exec\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`task_exec_iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_task_exec_iam_statements"></a> [task\_exec\_iam\_statements](#input\_task\_exec\_iam\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | <pre>map(object({<br/>    sid           = optional(string)<br/>    actions       = optional(list(string))<br/>    not_actions   = optional(list(string))<br/>    effect        = optional(string, "Allow")<br/>    resources     = optional(list(string))<br/>    not_resources = optional(list(string))<br/>    principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    not_principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    condition = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_task_exec_secret_arns"></a> [task\_exec\_secret\_arns](#input\_task\_exec\_secret\_arns) | List of SecretsManager secret ARNs the task execution role will be permitted to get/read | `list(string)` | `[]` | no |
| <a name="input_task_exec_ssm_param_arns"></a> [task\_exec\_ssm\_param\_arns](#input\_task\_exec\_ssm\_param\_arns) | List of SSM parameter ARNs the task execution role will be permitted to get/read | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_capacity_providers"></a> [autoscaling\_capacity\_providers](#output\_autoscaling\_capacity\_providers) | Map of autoscaling capacity providers created and their attributes |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of CloudWatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of CloudWatch log group created |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN that identifies the cluster |
| <a name="output_cluster_capacity_providers"></a> [cluster\_capacity\_providers](#output\_cluster\_capacity\_providers) | Map of cluster capacity providers attributes |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID that identifies the cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name that identifies the cluster |
| <a name="output_services"></a> [services](#output\_services) | Map of services created and their attributes |
| <a name="output_task_exec_iam_role_arn"></a> [task\_exec\_iam\_role\_arn](#output\_task\_exec\_iam\_role\_arn) | Task execution IAM role ARN |
| <a name="output_task_exec_iam_role_name"></a> [task\_exec\_iam\_role\_name](#output\_task\_exec\_iam\_role\_name) | Task execution IAM role name |
| <a name="output_task_exec_iam_role_unique_id"></a> [task\_exec\_iam\_role\_unique\_id](#output\_task\_exec\_iam\_role\_unique\_id) | Stable and unique string identifying the task execution IAM role |
<!-- END_TF_DOCS -->

## Authors

Module is maintained by [Anton Babenko](https://github.com/antonbabenko) with help from [these awesome contributors](https://github.com/terraform-aws-modules/terraform-aws-ecs/graphs/contributors).

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/LICENSE).
