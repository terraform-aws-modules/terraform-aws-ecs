# Amazon ECS Container Definition Module

Configuration in this directory creates an Amazon ECS container definition.

The module defaults to creating and utilizing a CloudWatch log group. You can disable this behavior by setting `enable_cloudwatch_logging` = `false` - useful for scenarios where Firelens is used for log forwarding.

For more details see the [design doc](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/docs/README.md)

## Usage

### Standard

```hcl
module "ecs_container_definition" {
  source = "terraform-aws-modules/ecs/aws//modules/container-definition"

  name      = "example"
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

  memoryReservation = 100

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### W/ Firelens

```hcl
module "fluentbit_ecs_container_definition" {
  source = "terraform-aws-modules/ecs/aws//modules/container-definition"
  name = "fluent-bit"

  cpu       = 512
  memory    = 1024
  essential = true
  image     = "906394416424.dkr.ecr.us-west-2.amazonaws.com/aws-for-fluent-bit:stable"
  firelensConfiguration = {
    type = "fluentbit"
  }
  memoryReservation = 50

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

module "example_ecs_container_definition" {
  source = "terraform-aws-modules/ecs/aws//modules/container-definition"

  name      = "example"
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

  tags = {
    Environment = "dev"
    Terraform   = "true"
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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.21 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_log_group_class"></a> [cloudwatch\_log\_group\_class](#input\_cloudwatch\_log\_group\_class) | Specified the log class of the log group. Possible values are: `STANDARD` or `INFREQUENT_ACCESS` | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch\_log\_group\_kms\_key\_id](#input\_cloudwatch\_log\_group\_kms\_key\_id) | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Custom name of CloudWatch log group for a service associated with the container definition | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events. Set to `0` to keep logs indefinitely | `number` | `14` | no |
| <a name="input_cloudwatch_log_group_use_name_prefix"></a> [cloudwatch\_log\_group\_use\_name\_prefix](#input\_cloudwatch\_log\_group\_use\_name\_prefix) | Determines whether the log group name should be used as a prefix | `bool` | `false` | no |
| <a name="input_command"></a> [command](#input\_command) | The command that's passed to the container | `list(string)` | `null` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of `cpu` of all containers in a task will need to be lower than the task-level cpu value | `number` | `null` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Determines whether a log group is created by this module. If not, AWS will automatically create one if logging is enabled | `bool` | `true` | no |
| <a name="input_credentialSpecs"></a> [credentialSpecs](#input\_credentialSpecs) | Specs for Credentials for gMSA (Windows containers). | `list(string)` | `null` | no |
| <a name="input_dependsOn"></a> [dependsOn](#input\_dependsOn) | The dependencies defined for container startup and shutdown. A container can contain multiple dependencies. When a dependency is defined for container startup, for container shutdown it is reversed. The condition can be one of START, COMPLETE, SUCCESS or HEALTHY | <pre>list(object({<br/>    condition     = string<br/>    containerName = string<br/>  }))</pre> | `null` | no |
| <a name="input_disableNetworking"></a> [disableNetworking](#input\_disableNetworking) | When this parameter is true, networking is disabled within the container | `bool` | `null` | no |
| <a name="input_dnsSearchDomains"></a> [dnsSearchDomains](#input\_dnsSearchDomains) | Container DNS search domains. A list of DNS search domains that are presented to the container | `list(string)` | `null` | no |
| <a name="input_dnsServers"></a> [dnsServers](#input\_dnsServers) | Container DNS servers. This is a list of strings specifying the IP addresses of the DNS servers | `list(string)` | `null` | no |
| <a name="input_dockerLabels"></a> [dockerLabels](#input\_dockerLabels) | A key/value map of labels to add to the container | `map(string)` | `null` | no |
| <a name="input_dockerSecurityOptions"></a> [dockerSecurityOptions](#input\_dockerSecurityOptions) | A list of strings to provide custom labels for SELinux and AppArmor multi-level security systems. This field isn't valid for containers in tasks using the Fargate launch type | `list(string)` | `null` | no |
| <a name="input_enable_cloudwatch_logging"></a> [enable\_cloudwatch\_logging](#input\_enable\_cloudwatch\_logging) | Determines whether CloudWatch logging is configured for this container definition. Set to `false` to use other logging drivers | `bool` | `true` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | Specifies whether to enable Amazon ECS Exec for the tasks within the service | `bool` | `false` | no |
| <a name="input_entrypoint"></a> [entrypoint](#input\_entrypoint) | The entry point that is passed to the container | `list(string)` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment variables to pass to the container | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `null` | no |
| <a name="input_environmentFiles"></a> [environmentFiles](#input\_environmentFiles) | A list of files containing the environment variables to pass to a container | <pre>list(object({<br/>    value = string<br/>    type  = string<br/>  }))</pre> | `null` | no |
| <a name="input_essential"></a> [essential](#input\_essential) | If the `essential` parameter of a container is marked as `true`, and that container fails or stops for any reason, all other containers that are part of the task are stopped | `bool` | `null` | no |
| <a name="input_extraHosts"></a> [extraHosts](#input\_extraHosts) | A list of hostnames and IP address mappings to append to the `/etc/hosts` file on the container | <pre>list(object({<br/>    hostname  = string<br/>    ipAddress = string<br/>  }))</pre> | `null` | no |
| <a name="input_firelensConfiguration"></a> [firelensConfiguration](#input\_firelensConfiguration) | The FireLens configuration for the container. This is used to specify and configure a log router for container logs. For more information, see [Custom Log Routing](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_firelens.html) in the Amazon Elastic Container Service Developer Guide | <pre>object({<br/>    options = optional(map(string))<br/>    type    = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_healthCheck"></a> [healthCheck](#input\_healthCheck) | The container health check command and associated configuration parameters for the container. See [HealthCheck](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html) | <pre>object({<br/>    command     = optional(list(string), [])<br/>    interval    = optional(number, 30)<br/>    retries     = optional(number, 3)<br/>    startPeriod = optional(number)<br/>    timeout     = optional(number, 5)<br/>  })</pre> | `null` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | The hostname to use for your container | `string` | `null` | no |
| <a name="input_image"></a> [image](#input\_image) | The image used to start a container. This string is passed directly to the Docker daemon. By default, images in the Docker Hub registry are available. Other repositories are specified with either `repository-url/image:tag` or `repository-url/image@digest` | `string` | `null` | no |
| <a name="input_interactive"></a> [interactive](#input\_interactive) | When this parameter is `true`, you can deploy containerized applications that require `stdin` or a `tty` to be allocated | `bool` | `false` | no |
| <a name="input_links"></a> [links](#input\_links) | The links parameter allows containers to communicate with each other without the need for port mappings. This parameter is only supported if the network mode of a task definition is `bridge` | `list(string)` | `null` | no |
| <a name="input_linuxParameters"></a> [linuxParameters](#input\_linuxParameters) | Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more information see [KernelCapabilities](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_KernelCapabilities.html) | <pre>object({<br/>    capabilities = optional(object({<br/>      add  = optional(list(string))<br/>      drop = optional(list(string))<br/>    }))<br/>    devices = optional(list(object({<br/>      containerPath = optional(string)<br/>      hostPath      = optional(string)<br/>      permissions   = optional(list(string))<br/>    })))<br/>    initProcessEnabled = optional(bool)<br/>    maxSwap            = optional(number)<br/>    sharedMemorySize   = optional(number)<br/>    swappiness         = optional(number)<br/>    tmpfs = optional(list(object({<br/>      containerPath = string<br/>      mountOptions  = optional(list(string))<br/>      size          = number<br/>    })))<br/>  })</pre> | `{}` | no |
| <a name="input_logConfiguration"></a> [logConfiguration](#input\_logConfiguration) | The log configuration for the container. For more information see [LogConfiguration](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html) | <pre>object({<br/>    logDriver = optional(string)<br/>    options   = optional(map(string))<br/>    secretOptions = optional(list(object({<br/>      name      = string<br/>      valueFrom = string<br/>    })))<br/>  })</pre> | `{}` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount (in MiB) of memory to present to the container. If your container attempts to exceed the memory specified here, the container is killed. The total amount of memory reserved for all containers within a task must be lower than the task `memory` value, if one is specified | `number` | `null` | no |
| <a name="input_memoryReservation"></a> [memoryReservation](#input\_memoryReservation) | The soft limit (in MiB) of memory to reserve for the container. When system memory is under heavy contention, Docker attempts to keep the container memory to this soft limit. However, your container can consume more memory when it needs to, up to either the hard limit specified with the `memory` parameter (if applicable), or all of the available memory on the container instance | `number` | `null` | no |
| <a name="input_mountPoints"></a> [mountPoints](#input\_mountPoints) | The mount points for data volumes in your container | <pre>list(object({<br/>    containerPath = optional(string)<br/>    readOnly      = optional(bool)<br/>    sourceVolume  = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of a container. If you're linking multiple containers together in a task definition, the name of one container can be entered in the links of another container to connect the containers. Up to 255 letters (uppercase and lowercase), numbers, underscores, and hyphens are allowed | `string` | `null` | no |
| <a name="input_operating_system_family"></a> [operating\_system\_family](#input\_operating\_system\_family) | The OS family for task | `string` | `"LINUX"` | no |
| <a name="input_portMappings"></a> [portMappings](#input\_portMappings) | The list of port mappings for the container. Port mappings allow containers to access ports on the host container instance to send or receive traffic. For task definitions that use the awsvpc network mode, only specify the containerPort. The hostPort can be left blank or it must be the same value as the containerPort | <pre>list(object({<br/>    appProtocol        = optional(string)<br/>    containerPort      = optional(number)<br/>    containerPortRange = optional(string)<br/>    hostPort           = optional(number)<br/>    name               = optional(string)<br/>    protocol           = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | When this parameter is true, the container is given elevated privileges on the host container instance (similar to the root user) | `bool` | `false` | no |
| <a name="input_pseudoTerminal"></a> [pseudoTerminal](#input\_pseudoTerminal) | When this parameter is true, a `TTY` is allocated | `bool` | `false` | no |
| <a name="input_readonlyRootFilesystem"></a> [readonlyRootFilesystem](#input\_readonlyRootFilesystem) | When this parameter is true, the container is given read-only access to its root file system | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_repositoryCredentials"></a> [repositoryCredentials](#input\_repositoryCredentials) | Container repository credentials; required when using a private repo.  This map currently supports a single key; "credentialsParameter", which should be the ARN of a Secrets Manager's secret holding the credentials | <pre>object({<br/>    credentialsParameter = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_resourceRequirements"></a> [resourceRequirements](#input\_resourceRequirements) | The type and amount of a resource to assign to a container. The only supported resource is a GPU | <pre>list(object({<br/>    type  = string<br/>    value = string<br/>  }))</pre> | `null` | no |
| <a name="input_restartPolicy"></a> [restartPolicy](#input\_restartPolicy) | Container restart policy; helps overcome transient failures faster and maintain task availability | <pre>object({<br/>    enabled              = optional(bool, true)<br/>    ignoredExitCodes     = optional(list(number))<br/>    restartAttemptPeriod = optional(number)<br/>  })</pre> | <pre>{<br/>  "enabled": true<br/>}</pre> | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | The secrets to pass to the container. For more information, see [Specifying Sensitive Data](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html) in the Amazon Elastic Container Service Developer Guide | <pre>list(object({<br/>    name      = string<br/>    valueFrom = string<br/>  }))</pre> | `null` | no |
| <a name="input_service"></a> [service](#input\_service) | The name of the service that the container definition is associated with. Used in CloudWatch log group default name (if one is not provided) | `string` | `null` | no |
| <a name="input_startTimeout"></a> [startTimeout](#input\_startTimeout) | Time duration (in seconds) to wait before giving up on resolving dependencies for a container | `number` | `30` | no |
| <a name="input_stopTimeout"></a> [stopTimeout](#input\_stopTimeout) | Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own | `number` | `120` | no |
| <a name="input_systemControls"></a> [systemControls](#input\_systemControls) | A list of namespaced kernel parameters to set in the container | <pre>list(object({<br/>    namespace = optional(string)<br/>    value     = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_ulimits"></a> [ulimits](#input\_ulimits) | A list of ulimits to set in the container. If a ulimit value is specified in a task definition, it overrides the default values set by Docker | <pre>list(object({<br/>    hardLimit = number<br/>    name      = string<br/>    softLimit = number<br/>  }))</pre> | `null` | no |
| <a name="input_user"></a> [user](#input\_user) | The user to run as inside the container. Can be any of these formats: user, user:group, uid, uid:gid, user:gid, uid:group. The default (null) will use the container's configured `USER` directive or root if not set | `string` | `null` | no |
| <a name="input_versionConsistency"></a> [versionConsistency](#input\_versionConsistency) | Specifies whether Amazon ECS will resolve the container image tag provided in the container definition to an image digest | `string` | `"disabled"` | no |
| <a name="input_volumesFrom"></a> [volumesFrom](#input\_volumesFrom) | Data volumes to mount from another container | <pre>list(object({<br/>    readOnly        = optional(bool)<br/>    sourceContainer = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_workingDirectory"></a> [workingDirectory](#input\_workingDirectory) | The working directory to run commands inside the container | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of CloudWatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of CloudWatch log group created |
| <a name="output_container_definition"></a> [container\_definition](#output\_container\_definition) | Container definition |
| <a name="output_container_definition_json"></a> [container\_definition\_json](#output\_container\_definition\_json) | Container definition. NOTE: use `jsonencode([module.ecs_container_definition.container_definition])` instead of this output when passing into a Task Definition |
<!-- END_TF_DOCS -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/LICENSE).
