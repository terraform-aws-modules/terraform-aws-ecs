# ECS Cluster w/ EC2 Autoscaling

Configuration in this directory creates:

- ECS cluster using EC2 autoscaling groups
- Autoscaling groups with IAM instance profile to be used by ECS cluster
- Example ECS service that utilizes
  - Mounts a host volume into the container definition
  - Load balancer target group attachment
  - Security group for access to the example service

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which will incur monetary charges on your AWS bill. Run `terraform destroy` when you no longer need these resources.

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
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | ~> 9.0 |
| <a name="module_autoscaling"></a> [autoscaling](#module\_autoscaling) | terraform-aws-modules/autoscaling/aws | ~> 6.5 |
| <a name="module_autoscaling_sg"></a> [autoscaling\_sg](#module\_autoscaling\_sg) | terraform-aws-modules/security-group/aws | ~> 5.0 |
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | ../../modules/cluster | n/a |
| <a name="module_ecs_service"></a> [ecs\_service](#module\_ecs\_service) | ../../modules/service | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_ssm_parameter.ecs_optimized_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN that identifies the cluster |
| <a name="output_cluster_autoscaling_capacity_providers"></a> [cluster\_autoscaling\_capacity\_providers](#output\_cluster\_autoscaling\_capacity\_providers) | Map of capacity providers created and their attributes |
| <a name="output_cluster_capacity_providers"></a> [cluster\_capacity\_providers](#output\_cluster\_capacity\_providers) | Map of cluster capacity providers attributes |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID that identifies the cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name that identifies the cluster |
| <a name="output_service_autoscaling_policies"></a> [service\_autoscaling\_policies](#output\_service\_autoscaling\_policies) | Map of autoscaling policies and their attributes |
| <a name="output_service_autoscaling_scheduled_actions"></a> [service\_autoscaling\_scheduled\_actions](#output\_service\_autoscaling\_scheduled\_actions) | Map of autoscaling scheduled actions and their attributes |
| <a name="output_service_container_definitions"></a> [service\_container\_definitions](#output\_service\_container\_definitions) | Container definitions |
| <a name="output_service_iam_role_arn"></a> [service\_iam\_role\_arn](#output\_service\_iam\_role\_arn) | Service IAM role ARN |
| <a name="output_service_iam_role_name"></a> [service\_iam\_role\_name](#output\_service\_iam\_role\_name) | Service IAM role name |
| <a name="output_service_iam_role_unique_id"></a> [service\_iam\_role\_unique\_id](#output\_service\_iam\_role\_unique\_id) | Stable and unique string identifying the service IAM role |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | ARN that identifies the service |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Name of the service |
| <a name="output_service_task_definition_arn"></a> [service\_task\_definition\_arn](#output\_service\_task\_definition\_arn) | Full ARN of the Task Definition (including both `family` and `revision`) |
| <a name="output_service_task_definition_revision"></a> [service\_task\_definition\_revision](#output\_service\_task\_definition\_revision) | Revision of the task in a particular family |
| <a name="output_service_task_exec_iam_role_arn"></a> [service\_task\_exec\_iam\_role\_arn](#output\_service\_task\_exec\_iam\_role\_arn) | Task execution IAM role ARN |
| <a name="output_service_task_exec_iam_role_name"></a> [service\_task\_exec\_iam\_role\_name](#output\_service\_task\_exec\_iam\_role\_name) | Task execution IAM role name |
| <a name="output_service_task_exec_iam_role_unique_id"></a> [service\_task\_exec\_iam\_role\_unique\_id](#output\_service\_task\_exec\_iam\_role\_unique\_id) | Stable and unique string identifying the task execution IAM role |
| <a name="output_service_task_set_arn"></a> [service\_task\_set\_arn](#output\_service\_task\_set\_arn) | The Amazon Resource Name (ARN) that identifies the task set |
| <a name="output_service_task_set_id"></a> [service\_task\_set\_id](#output\_service\_task\_set\_id) | The ID of the task set |
| <a name="output_service_task_set_stability_status"></a> [service\_task\_set\_stability\_status](#output\_service\_task\_set\_stability\_status) | The stability status. This indicates whether the task set has reached a steady state |
| <a name="output_service_task_set_status"></a> [service\_task\_set\_status](#output\_service\_task\_set\_status) | The status of the task set |
| <a name="output_service_tasks_iam_role_arn"></a> [service\_tasks\_iam\_role\_arn](#output\_service\_tasks\_iam\_role\_arn) | Tasks IAM role ARN |
| <a name="output_service_tasks_iam_role_name"></a> [service\_tasks\_iam\_role\_name](#output\_service\_tasks\_iam\_role\_name) | Tasks IAM role name |
| <a name="output_service_tasks_iam_role_unique_id"></a> [service\_tasks\_iam\_role\_unique\_id](#output\_service\_tasks\_iam\_role\_unique\_id) | Stable and unique string identifying the tasks IAM role |
<!-- END_TF_DOCS -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/LICENSE).
