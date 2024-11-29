# Amazon ECS Service Module

Configuration in this directory creates an Amazon ECS Service and associated resources.

Some notable configurations to be aware of when using this module:
1. `desired_count`/`scale` is always ignored; the module is designed to utilize autoscaling by default (though it can be disabled)
2. The default configuration is intended for `FARGATE` use

For more details see the [design doc](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/docs/README.md)

### Logging

Please refer to [FireLens examples repository](https://github.com/aws-samples/amazon-ecs-firelens-examples) for logging configuration examples for FireLens on Amazon ECS and AWS Fargate.

## Usage

```hcl
module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name        = "example"
  cluster_arn = "arn:aws:ecs:us-west-2:123456789012:cluster/default"

  cpu    = 1024
  memory = 4096

  # Container definition(s)
  container_definitions = {

    fluent-bit = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "906394416424.dkr.ecr.us-west-2.amazonaws.com/aws-for-fluent-bit:stable"
      firelens_configuration = {
        type = "fluentbit"
      }
      memory_reservation = 50
    }

    ecs-sample = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
      port_mappings = [
        {
          name          = "ecs-sample"
          containerPort = 80
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
          region                  = "eu-west-1"
          delivery_stream         = "my-stream"
          log-driver-buffer-limit = "2097152"
        }
      }
      memory_reservation = 100
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
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = "sg-12345678"
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Conditional Creation

The following values are provided to toggle on/off creation of the associated resources as desired:

```hcl
module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  # Disable creation of service and all resources
  create = false

  # Enable ECS Exec
  enable_execute_command = true

  # Disable creation of the service IAM role; `iam_role_arn` should be provided
  create_iam_role = false

  # Disable creation of the task definition; `task_definition_arn` should be provided
  create_task_definition = false

  # Disable creation of the task execution IAM role; `task_exec_iam_role_arn` should be provided
  create_task_exec_iam_role = false

  # Disable creation of the task execution IAM role policy
  create_task_exec_policy = false

  # Disable creation of the tasks IAM role; `tasks_iam_role_arn` should be provided
  create_tasks_iam_role = false

  # Disable creation of the service security group
  create_security_group = false

  # ... omitted
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.66.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.66.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_container_definition"></a> [container\_definition](#module\_container\_definition) | ../container-definition | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_scheduled_action.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_ecs_service.ignore_task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ecs_task_set.ignore_task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_set) | resource |
| [aws_ecs_task_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_set) | resource |
| [aws_iam_policy.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task_exec_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) | data source |
| [aws_iam_policy_document.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.service_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_exec_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tasks_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarms"></a> [alarms](#input\_alarms) | Information about the CloudWatch alarms | `any` | `{}` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign a public IP address to the ENI (Fargate launch type only) | `bool` | `false` | no |
| <a name="input_autoscaling_max_capacity"></a> [autoscaling\_max\_capacity](#input\_autoscaling\_max\_capacity) | Maximum number of tasks to run in your service | `number` | `10` | no |
| <a name="input_autoscaling_min_capacity"></a> [autoscaling\_min\_capacity](#input\_autoscaling\_min\_capacity) | Minimum number of tasks to run in your service | `number` | `1` | no |
| <a name="input_autoscaling_policies"></a> [autoscaling\_policies](#input\_autoscaling\_policies) | Map of autoscaling policies to create for the service | `any` | <pre>{<br/>  "cpu": {<br/>    "policy_type": "TargetTrackingScaling",<br/>    "target_tracking_scaling_policy_configuration": {<br/>      "predefined_metric_specification": {<br/>        "predefined_metric_type": "ECSServiceAverageCPUUtilization"<br/>      }<br/>    }<br/>  },<br/>  "memory": {<br/>    "policy_type": "TargetTrackingScaling",<br/>    "target_tracking_scaling_policy_configuration": {<br/>      "predefined_metric_specification": {<br/>        "predefined_metric_type": "ECSServiceAverageMemoryUtilization"<br/>      }<br/>    }<br/>  }<br/>}</pre> | no |
| <a name="input_autoscaling_scheduled_actions"></a> [autoscaling\_scheduled\_actions](#input\_autoscaling\_scheduled\_actions) | Map of autoscaling scheduled actions to create for the service | `any` | `{}` | no |
| <a name="input_capacity_provider_strategy"></a> [capacity\_provider\_strategy](#input\_capacity\_provider\_strategy) | Capacity provider strategies to use for the service. Can be one or more | `any` | `{}` | no |
| <a name="input_cluster_arn"></a> [cluster\_arn](#input\_cluster\_arn) | ARN of the ECS cluster where the resources will be provisioned | `string` | `""` | no |
| <a name="input_container_definition_defaults"></a> [container\_definition\_defaults](#input\_container\_definition\_defaults) | A map of default values for [container definitions](http://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html) created by `container_definitions` | `any` | `{}` | no |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | A map of valid [container definitions](http://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html). Please note that you should only provide values that are part of the container definition document | `any` | `{}` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Number of cpu units used by the task. If the `requires_compatibilities` is `FARGATE` this field is required | `number` | `1024` | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether resources will be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Determines whether the ECS service IAM role should be created | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Determines if a security group is created | `bool` | `true` | no |
| <a name="input_create_service"></a> [create\_service](#input\_create\_service) | Determines whether service resource will be created (set to `false` in case you want to create task definition only) | `bool` | `true` | no |
| <a name="input_create_task_definition"></a> [create\_task\_definition](#input\_create\_task\_definition) | Determines whether to create a task definition or use existing/provided | `bool` | `true` | no |
| <a name="input_create_task_exec_iam_role"></a> [create\_task\_exec\_iam\_role](#input\_create\_task\_exec\_iam\_role) | Determines whether the ECS task definition IAM role should be created | `bool` | `true` | no |
| <a name="input_create_task_exec_policy"></a> [create\_task\_exec\_policy](#input\_create\_task\_exec\_policy) | Determines whether the ECS task definition IAM policy should be created. This includes permissions included in AmazonECSTaskExecutionRolePolicy as well as access to secrets and SSM parameters | `bool` | `true` | no |
| <a name="input_create_tasks_iam_role"></a> [create\_tasks\_iam\_role](#input\_create\_tasks\_iam\_role) | Determines whether the ECS tasks IAM role should be created | `bool` | `true` | no |
| <a name="input_deployment_circuit_breaker"></a> [deployment\_circuit\_breaker](#input\_deployment\_circuit\_breaker) | Configuration block for deployment circuit breaker | `any` | `{}` | no |
| <a name="input_deployment_controller"></a> [deployment\_controller](#input\_deployment\_controller) | Configuration block for deployment controller configuration | `any` | `{}` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | Upper limit (as a percentage of the service's `desired_count`) of the number of running tasks that can be running in a service during a deployment | `number` | `200` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | Lower limit (as a percentage of the service's `desired_count`) of the number of running tasks that must remain running and healthy in a service during a deployment | `number` | `66` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Number of instances of the task definition to place and keep running | `number` | `1` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Determines whether to enable autoscaling for the service | `bool` | `true` | no |
| <a name="input_enable_ecs_managed_tags"></a> [enable\_ecs\_managed\_tags](#input\_enable\_ecs\_managed\_tags) | Specifies whether to enable Amazon ECS managed tags for the tasks within the service | `bool` | `true` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | Specifies whether to enable Amazon ECS Exec for the tasks within the service | `bool` | `false` | no |
| <a name="input_ephemeral_storage"></a> [ephemeral\_storage](#input\_ephemeral\_storage) | The amount of ephemeral storage to allocate for the task. This parameter is used to expand the total amount of ephemeral storage available, beyond the default amount, for tasks hosted on AWS Fargate | `any` | `{}` | no |
| <a name="input_external_id"></a> [external\_id](#input\_external\_id) | The external ID associated with the task set | `string` | `null` | no |
| <a name="input_family"></a> [family](#input\_family) | A unique name for your task definition | `string` | `null` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Whether to allow deleting the task set without waiting for scaling down to 0 | `bool` | `null` | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination, roll Fargate tasks onto a newer platform version, or immediately deploy `ordered_placement_strategy` and `placement_constraints` updates | `bool` | `true` | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers | `number` | `null` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Existing IAM role ARN | `string` | `null` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_statements"></a> [iam\_role\_statements](#input\_iam\_role\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | `any` | `{}` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_ignore_task_definition_changes"></a> [ignore\_task\_definition\_changes](#input\_ignore\_task\_definition\_changes) | Whether changes to service `task_definition` changes should be ignored | `bool` | `false` | no |
| <a name="input_inference_accelerator"></a> [inference\_accelerator](#input\_inference\_accelerator) | Configuration block(s) with Inference Accelerators settings | `any` | `{}` | no |
| <a name="input_ipc_mode"></a> [ipc\_mode](#input\_ipc\_mode) | IPC resource namespace to be used for the containers in the task The valid values are `host`, `task`, and `none` | `string` | `null` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | Launch type on which to run your service. The valid values are `EC2`, `FARGATE`, and `EXTERNAL`. Defaults to `FARGATE` | `string` | `"FARGATE"` | no |
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | Configuration block for load balancers | `any` | `{}` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount (in MiB) of memory used by the task. If the `requires_compatibilities` is `FARGATE` this field is required | `number` | `2048` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the service (up to 255 letters, numbers, hyphens, and underscores) | `string` | `null` | no |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | Docker networking mode to use for the containers in the task. Valid values are `none`, `bridge`, `awsvpc`, and `host` | `string` | `"awsvpc"` | no |
| <a name="input_ordered_placement_strategy"></a> [ordered\_placement\_strategy](#input\_ordered\_placement\_strategy) | Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence | `any` | `{}` | no |
| <a name="input_pid_mode"></a> [pid\_mode](#input\_pid\_mode) | Process namespace to use for the containers in the task. The valid values are `host` and `task` | `string` | `null` | no |
| <a name="input_placement_constraints"></a> [placement\_constraints](#input\_placement\_constraints) | Configuration block for rules that are taken into consideration during task placement (up to max of 10). This is set at the service, see `task_definition_placement_constraints` for setting at the task definition | `any` | `{}` | no |
| <a name="input_platform_version"></a> [platform\_version](#input\_platform\_version) | Platform version on which to run your service. Only applicable for `launch_type` set to `FARGATE`. Defaults to `LATEST` | `string` | `null` | no |
| <a name="input_propagate_tags"></a> [propagate\_tags](#input\_propagate\_tags) | Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are `SERVICE` and `TASK_DEFINITION` | `string` | `null` | no |
| <a name="input_proxy_configuration"></a> [proxy\_configuration](#input\_proxy\_configuration) | Configuration block for the App Mesh proxy | `any` | `{}` | no |
| <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities) | Set of launch types required by the task. The valid values are `EC2` and `FARGATE` | `list(string)` | <pre>[<br/>  "FARGATE"<br/>]</pre> | no |
| <a name="input_runtime_platform"></a> [runtime\_platform](#input\_runtime\_platform) | Configuration block for `runtime_platform` that containers in your task may use | `any` | <pre>{<br/>  "cpu_architecture": "X86_64",<br/>  "operating_system_family": "LINUX"<br/>}</pre> | no |
| <a name="input_scale"></a> [scale](#input\_scale) | A floating-point percentage of the desired number of tasks to place and keep running in the task set | `any` | `{}` | no |
| <a name="input_scheduling_strategy"></a> [scheduling\_strategy](#input\_scheduling\_strategy) | Scheduling strategy to use for the service. The valid values are `REPLICA` and `DAEMON`. Defaults to `REPLICA` | `string` | `null` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description of the security group created | `string` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security groups to associate with the task or service | `list(string)` | `[]` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name to use on security group created | `string` | `null` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | Security group rules to add to the security group created | `any` | `{}` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | A map of additional tags to add to the security group created | `map(string)` | `{}` | no |
| <a name="input_security_group_use_name_prefix"></a> [security\_group\_use\_name\_prefix](#input\_security\_group\_use\_name\_prefix) | Determines whether the security group name (`security_group_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_service_connect_configuration"></a> [service\_connect\_configuration](#input\_service\_connect\_configuration) | The ECS Service Connect configuration for this service to discover and connect to services, and be discovered by, and connected from, other services within a namespace | `any` | `{}` | no |
| <a name="input_service_registries"></a> [service\_registries](#input\_service\_registries) | Service discovery registries for the service | `any` | `{}` | no |
| <a name="input_service_tags"></a> [service\_tags](#input\_service\_tags) | A map of additional tags to add to the service | `map(string)` | `{}` | no |
| <a name="input_skip_destroy"></a> [skip\_destroy](#input\_skip\_destroy) | If true, the task is not deleted when the service is deleted | `bool` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnets to associate with the task or service | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_task_definition_arn"></a> [task\_definition\_arn](#input\_task\_definition\_arn) | Existing task definition ARN. Required when `create_task_definition` is `false` | `string` | `null` | no |
| <a name="input_task_definition_placement_constraints"></a> [task\_definition\_placement\_constraints](#input\_task\_definition\_placement\_constraints) | Configuration block for rules that are taken into consideration during task placement (up to max of 10). This is set at the task definition, see `placement_constraints` for setting at the service | `any` | `{}` | no |
| <a name="input_task_exec_iam_policy_path"></a> [task\_exec\_iam\_policy\_path](#input\_task\_exec\_iam\_policy\_path) | Path for the iam role | `string` | `null` | no |
| <a name="input_task_exec_iam_role_arn"></a> [task\_exec\_iam\_role\_arn](#input\_task\_exec\_iam\_role\_arn) | Existing IAM role ARN | `string` | `null` | no |
| <a name="input_task_exec_iam_role_description"></a> [task\_exec\_iam\_role\_description](#input\_task\_exec\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_task_exec_iam_role_max_session_duration"></a> [task\_exec\_iam\_role\_max\_session\_duration](#input\_task\_exec\_iam\_role\_max\_session\_duration) | Maximum session duration (in seconds) for ECS task execution role. Default is 3600. | `number` | `null` | no |
| <a name="input_task_exec_iam_role_name"></a> [task\_exec\_iam\_role\_name](#input\_task\_exec\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_task_exec_iam_role_path"></a> [task\_exec\_iam\_role\_path](#input\_task\_exec\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_task_exec_iam_role_permissions_boundary"></a> [task\_exec\_iam\_role\_permissions\_boundary](#input\_task\_exec\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_task_exec_iam_role_policies"></a> [task\_exec\_iam\_role\_policies](#input\_task\_exec\_iam\_role\_policies) | Map of IAM role policy ARNs to attach to the IAM role | `map(string)` | `{}` | no |
| <a name="input_task_exec_iam_role_tags"></a> [task\_exec\_iam\_role\_tags](#input\_task\_exec\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_task_exec_iam_role_use_name_prefix"></a> [task\_exec\_iam\_role\_use\_name\_prefix](#input\_task\_exec\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`task_exec_iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_task_exec_iam_statements"></a> [task\_exec\_iam\_statements](#input\_task\_exec\_iam\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | `any` | `{}` | no |
| <a name="input_task_exec_secret_arns"></a> [task\_exec\_secret\_arns](#input\_task\_exec\_secret\_arns) | List of SecretsManager secret ARNs the task execution role will be permitted to get/read | `list(string)` | <pre>[<br/>  "arn:aws:secretsmanager:*:*:secret:*"<br/>]</pre> | no |
| <a name="input_task_exec_ssm_param_arns"></a> [task\_exec\_ssm\_param\_arns](#input\_task\_exec\_ssm\_param\_arns) | List of SSM parameter ARNs the task execution role will be permitted to get/read | `list(string)` | <pre>[<br/>  "arn:aws:ssm:*:*:parameter/*"<br/>]</pre> | no |
| <a name="input_task_tags"></a> [task\_tags](#input\_task\_tags) | A map of additional tags to add to the task definition/set created | `map(string)` | `{}` | no |
| <a name="input_tasks_iam_role_arn"></a> [tasks\_iam\_role\_arn](#input\_tasks\_iam\_role\_arn) | Existing IAM role ARN | `string` | `null` | no |
| <a name="input_tasks_iam_role_description"></a> [tasks\_iam\_role\_description](#input\_tasks\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_tasks_iam_role_name"></a> [tasks\_iam\_role\_name](#input\_tasks\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_tasks_iam_role_path"></a> [tasks\_iam\_role\_path](#input\_tasks\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_tasks_iam_role_permissions_boundary"></a> [tasks\_iam\_role\_permissions\_boundary](#input\_tasks\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_tasks_iam_role_policies"></a> [tasks\_iam\_role\_policies](#input\_tasks\_iam\_role\_policies) | Map of IAM role policy ARNs to attach to the IAM role | `map(string)` | `{}` | no |
| <a name="input_tasks_iam_role_statements"></a> [tasks\_iam\_role\_statements](#input\_tasks\_iam\_role\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | `any` | `{}` | no |
| <a name="input_tasks_iam_role_tags"></a> [tasks\_iam\_role\_tags](#input\_tasks\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_tasks_iam_role_use_name_prefix"></a> [tasks\_iam\_role\_use\_name\_prefix](#input\_tasks\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`tasks_iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Create, update, and delete timeout configurations for the service | `map(string)` | `{}` | no |
| <a name="input_triggers"></a> [triggers](#input\_triggers) | Map of arbitrary keys and values that, when changed, will trigger an in-place update (redeployment). Useful with `timestamp()` | `any` | `{}` | no |
| <a name="input_volume"></a> [volume](#input\_volume) | Configuration block for volumes that containers in your task may use | `any` | `{}` | no |
| <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state) | If true, Terraform will wait for the service to reach a steady state before continuing. Default is `false` | `bool` | `null` | no |
| <a name="input_wait_until_stable"></a> [wait\_until\_stable](#input\_wait\_until\_stable) | Whether terraform should wait until the task set has reached `STEADY_STATE` | `bool` | `null` | no |
| <a name="input_wait_until_stable_timeout"></a> [wait\_until\_stable\_timeout](#input\_wait\_until\_stable\_timeout) | Wait timeout for task set to reach `STEADY_STATE`. Valid time units include `ns`, `us` (or µs), `ms`, `s`, `m`, and `h`. Default `10m` | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_policies"></a> [autoscaling\_policies](#output\_autoscaling\_policies) | Map of autoscaling policies and their attributes |
| <a name="output_autoscaling_scheduled_actions"></a> [autoscaling\_scheduled\_actions](#output\_autoscaling\_scheduled\_actions) | Map of autoscaling scheduled actions and their attributes |
| <a name="output_container_definitions"></a> [container\_definitions](#output\_container\_definitions) | Container definitions |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | Service IAM role ARN |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Service IAM role name |
| <a name="output_iam_role_unique_id"></a> [iam\_role\_unique\_id](#output\_iam\_role\_unique\_id) | Stable and unique string identifying the service IAM role |
| <a name="output_id"></a> [id](#output\_id) | ARN that identifies the service |
| <a name="output_name"></a> [name](#output\_name) | Name of the service |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Amazon Resource Name (ARN) of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | Full ARN of the Task Definition (including both `family` and `revision`) |
| <a name="output_task_definition_family"></a> [task\_definition\_family](#output\_task\_definition\_family) | The unique name of the task definition |
| <a name="output_task_definition_family_revision"></a> [task\_definition\_family\_revision](#output\_task\_definition\_family\_revision) | The family and revision (family:revision) of the task definition |
| <a name="output_task_definition_revision"></a> [task\_definition\_revision](#output\_task\_definition\_revision) | Revision of the task in a particular family |
| <a name="output_task_exec_iam_role_arn"></a> [task\_exec\_iam\_role\_arn](#output\_task\_exec\_iam\_role\_arn) | Task execution IAM role ARN |
| <a name="output_task_exec_iam_role_name"></a> [task\_exec\_iam\_role\_name](#output\_task\_exec\_iam\_role\_name) | Task execution IAM role name |
| <a name="output_task_exec_iam_role_unique_id"></a> [task\_exec\_iam\_role\_unique\_id](#output\_task\_exec\_iam\_role\_unique\_id) | Stable and unique string identifying the task execution IAM role |
| <a name="output_task_set_arn"></a> [task\_set\_arn](#output\_task\_set\_arn) | The Amazon Resource Name (ARN) that identifies the task set |
| <a name="output_task_set_id"></a> [task\_set\_id](#output\_task\_set\_id) | The ID of the task set |
| <a name="output_task_set_stability_status"></a> [task\_set\_stability\_status](#output\_task\_set\_stability\_status) | The stability status. This indicates whether the task set has reached a steady state |
| <a name="output_task_set_status"></a> [task\_set\_status](#output\_task\_set\_status) | The status of the task set |
| <a name="output_tasks_iam_role_arn"></a> [tasks\_iam\_role\_arn](#output\_tasks\_iam\_role\_arn) | Tasks IAM role ARN |
| <a name="output_tasks_iam_role_name"></a> [tasks\_iam\_role\_name](#output\_tasks\_iam\_role\_name) | Tasks IAM role name |
| <a name="output_tasks_iam_role_unique_id"></a> [tasks\_iam\_role\_unique\_id](#output\_tasks\_iam\_role\_unique\_id) | Stable and unique string identifying the tasks IAM role |
<!-- END_TF_DOCS -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/LICENSE).
