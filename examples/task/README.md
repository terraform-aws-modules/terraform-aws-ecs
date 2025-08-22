# ECS Task Definition Example

Configuration in this directory creates:

- ECS Task Definition using the standalone task module
- ECS Cluster with a task definition using the complete module
- Associated IAM roles for task execution and tasks

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

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 6.4   |

## Providers

No providers.

## Modules

| Name                                                                    | Source             | Version |
| ----------------------------------------------------------------------- | ------------------ | ------- |
| <a name="module_ecs_complete"></a> [ecs_complete](#module_ecs_complete) | ../../             | n/a     |
| <a name="module_ecs_task"></a> [ecs_task](#module_ecs_task)             | ../../modules/task | n/a     |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name                                                                                                  | Description                               |
| ----------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| <a name="output_cluster_arn"></a> [cluster_arn](#output_cluster_arn)                                  | ARN that identifies the cluster           |
| <a name="output_cluster_id"></a> [cluster_id](#output_cluster_id)                                     | ID that identifies the cluster            |
| <a name="output_cluster_name"></a> [cluster_name](#output_cluster_name)                               | Name that identifies the cluster          |
| <a name="output_task_definition_arn"></a> [task_definition_arn](#output_task_definition_arn)          | Full ARN of the task definition           |
| <a name="output_task_definition_family"></a> [task_definition_family](#output_task_definition_family) | The unique name of the task definition    |
| <a name="output_task_exec_iam_role_arn"></a> [task_exec_iam_role_arn](#output_task_exec_iam_role_arn) | Task execution IAM role ARN               |
| <a name="output_tasks"></a> [tasks](#output_tasks)                                                    | Map of tasks created and their attributes |
| <a name="output_tasks_iam_role_arn"></a> [tasks_iam_role_arn](#output_tasks_iam_role_arn)             | Tasks IAM role ARN                        |

<!-- END_TF_DOCS -->
