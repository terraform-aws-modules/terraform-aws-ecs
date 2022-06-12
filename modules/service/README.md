# ECS Service Module

Configuration in this directory creates an ECS Service EKS Profile

⚠️ Module is under active development ⚠️

## TODO

- [ ] `aws_ecs_service` (one default, one with `ignore_changes` for things like `desired_count`)
- [ ] `aws_ecs_task_definition`
- [ ] `aws_ecs_task_set`
- [ ] `aws_appautoscaling_target` & `aws_appautoscaling_policy` (`for_each` over a shared map where each key = 1 target and 2 policies, 1 policy for scale up, 1 for scale down)
- [ ] Task role (`aws_iam_role`, `aws_iam_role_policy_attachment`, assume role `aws_iam_policy_document`)
- [ ] Task exectution role (`aws_iam_role`, `aws_iam_role_policy_attachment`, assume role `aws_iam_policy_document`)
- [ ] ECS CloudWatch events role (`aws_iam_role`, `aws_iam_role_policy_attachment`, assume role `aws_iam_policy_document`)

## Usage

```hcl
module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name       = "MyService"
  cluster_id = module.ecs.cluster_id

  # TODO

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### Logging

Please refer to https://github.com/aws-samples/amazon-ecs-firelens-examples for logging architectures for FireLens on Amazon ECS and AWS Fargate.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_service.idc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity_provider_strategy"></a> [capacity\_provider\_strategy](#input\_capacity\_provider\_strategy) | Capacity provider strategies to use for the service. Can be one or more | `any` | `{}` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | ARN of an ECS cluster | `string` | `""` | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether resources will be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_task_definition"></a> [create\_task\_definition](#input\_create\_task\_definition) | Determines whether to create a task definition or use existing/provided | `bool` | `true` | no |
| <a name="input_deployment_circuit_breaker"></a> [deployment\_circuit\_breaker](#input\_deployment\_circuit\_breaker) | Configuration block for deployment circuit breaker | `any` | `{}` | no |
| <a name="input_deployment_controller"></a> [deployment\_controller](#input\_deployment\_controller) | Configuration block for deployment controller configuration | `any` | `{}` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | Upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment | `number` | `null` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | Lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment | `number` | `null` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Number of instances of the task definition to place and keep running. Defaults to `0` | `number` | `null` | no |
| <a name="input_enable_ecs_managed_tags"></a> [enable\_ecs\_managed\_tags](#input\_enable\_ecs\_managed\_tags) | Specifies whether to enable Amazon ECS managed tags for the tasks within the service | `bool` | `null` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | Specifies whether to enable Amazon ECS Exec for the tasks within the service | `bool` | `null` | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination, roll Fargate tasks onto a newer platform version, or immediately deploy `ordered_placement_strategy` and `placement_constraints` updates | `bool` | `null` | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers | `number` | `null` | no |
| <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role) | ARN of the IAM role that allows Amazon ECS to make calls to your load balancer on your behalf | `string` | `null` | no |
| <a name="input_ignore_desired_count_changes"></a> [ignore\_desired\_count\_changes](#input\_ignore\_desired\_count\_changes) | Whether changes to service `desired_count` changes should be ignored. Used for autoscaling of tasks; will replace entire service when changed | `bool` | `true` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | Launch type on which to run your service. The valid values are `EC2`, `FARGATE`, and `EXTERNAL`. Defaults to `EC2` | `string` | `null` | no |
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | Configuration block for load balancers | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the service (up to 255 letters, numbers, hyphens, and underscores) | `string` | `null` | no |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | Network configuration for the service. This parameter is required for task definitions that use the awsvpc network mode to receive their own Elastic Network Interface, and it is not supported for other network modes | `any` | `{}` | no |
| <a name="input_ordered_placement_strategy"></a> [ordered\_placement\_strategy](#input\_ordered\_placement\_strategy) | Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence | `any` | `{}` | no |
| <a name="input_placement_constraints"></a> [placement\_constraints](#input\_placement\_constraints) | Rules that are taken into consideration during task placement | `any` | `{}` | no |
| <a name="input_platform_version"></a> [platform\_version](#input\_platform\_version) | Platform version on which to run your service. Only applicable for `launch_type` set to `FARGATE`. Defaults to `LATEST` | `string` | `null` | no |
| <a name="input_propagate_tags"></a> [propagate\_tags](#input\_propagate\_tags) | Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are `SERVICE` and `TASK_DEFINITION` | `bool` | `null` | no |
| <a name="input_scheduling_strategy"></a> [scheduling\_strategy](#input\_scheduling\_strategy) | Scheduling strategy to use for the service. The valid values are `REPLICA` and `DAEMON`. Defaults to `REPLICA` | `string` | `null` | no |
| <a name="input_service_registries"></a> [service\_registries](#input\_service\_registries) | Service discovery registries for the service | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_task_container_definitions"></a> [task\_container\_definitions](#input\_task\_container\_definitions) | A list of valid [container definitions](http://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html) provided as a single valid JSON document. Please note that you should only provide values that are part of the container definition document | `string` | `""` | no |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | Number of cpu units used by the task. If the `task_requires_compatibilities` is `FARGATE` this field is required | `number` | `null` | no |
| <a name="input_task_definition"></a> [task\_definition](#input\_task\_definition) | Family and revision (`family:revision`) or full ARN of the task definition that you want to run in your service. Required unless using the `EXTERNAL` deployment controller | `string` | `null` | no |
| <a name="input_task_ephemeral_storage"></a> [task\_ephemeral\_storage](#input\_task\_ephemeral\_storage) | The amount of ephemeral storage to allocate for the task. This parameter is used to expand the total amount of ephemeral storage available, beyond the default amount, for tasks hosted on AWS Fargate | `any` | `{}` | no |
| <a name="input_task_execution_role_arn"></a> [task\_execution\_role\_arn](#input\_task\_execution\_role\_arn) | ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume | `string` | `null` | no |
| <a name="input_task_family"></a> [task\_family](#input\_task\_family) | A unique name for your task definition | `string` | `null` | no |
| <a name="input_task_inference_accelerator"></a> [task\_inference\_accelerator](#input\_task\_inference\_accelerator) | Configuration block(s) with Inference Accelerators settings | `any` | `{}` | no |
| <a name="input_task_ipc_mode"></a> [task\_ipc\_mode](#input\_task\_ipc\_mode) | IPC resource namespace to be used for the containers in the task The valid values are `host`, `task`, and `none` | `string` | `null` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | Amount (in MiB) of memory used by the task. If the `task_requires_compatibilities` is `FARGATE` this field is required | `number` | `null` | no |
| <a name="input_task_network_mode"></a> [task\_network\_mode](#input\_task\_network\_mode) | Docker networking mode to use for the containers in the task. Valid values are `none`, `bridge`, `awsvpc`, and `host` | `string` | `null` | no |
| <a name="input_task_pid_mode"></a> [task\_pid\_mode](#input\_task\_pid\_mode) | Process namespace to use for the containers in the task. The valid values are `host` and `task` | `string` | `null` | no |
| <a name="input_task_placement_constraints"></a> [task\_placement\_constraints](#input\_task\_placement\_constraints) | Configuration block for rules that are taken into consideration during task placement (up to max of 10) | `any` | `{}` | no |
| <a name="input_task_proxy_configuration"></a> [task\_proxy\_configuration](#input\_task\_proxy\_configuration) | Configuration block for the App Mesh proxy | `any` | `{}` | no |
| <a name="input_task_requires_compatibilities"></a> [task\_requires\_compatibilities](#input\_task\_requires\_compatibilities) | Set of launch types required by the task. The valid values are `EC2` and `FARGATE` | `list(string)` | `[]` | no |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services | `string` | `null` | no |
| <a name="input_task_runtime_platform"></a> [task\_runtime\_platform](#input\_task\_runtime\_platform) | Configuration block for `task_runtime_platform` that containers in your task may use | `any` | `{}` | no |
| <a name="input_task_skip_destroy"></a> [task\_skip\_destroy](#input\_task\_skip\_destroy) | If true, the task is not deleted when the service is deleted | `bool` | `null` | no |
| <a name="input_task_volume"></a> [task\_volume](#input\_task\_volume) | Configuration block for volumes that containers in your task may use | `any` | `{}` | no |
| <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state) | If true, Terraform will wait for the service to reach a steady state before continuing. Default is `false` | `bool` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ARN that identifies the service |
| <a name="output_name"></a> [name](#output\_name) | Name of the service |
| <a name="output_task_arn"></a> [task\_arn](#output\_task\_arn) | Full ARN of the Task Definition (including both `family` and `revision`) |
| <a name="output_task_revision"></a> [task\_revision](#output\_task\_revision) | Revision of the task in a particular family |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
