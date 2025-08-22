# AWS ECS Task Terraform sub-module

Terraform sub-module which creates ECS (Elastic Container Service) task definition and related IAM resources on AWS.

## Usage

```hcl
module "ecs_task" {
  source = "terraform-aws-modules/ecs/aws//modules/task"

  name = "my-task"

  container_definitions = {
    app = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "nginx:latest"
      portMappings = [
        {
          name          = "app"
          containerPort = 80
          protocol      = "tcp"
        }
      ]
    }
  }

  # Task execution IAM role
  create_task_exec_iam_role = true
  task_exec_iam_role_name   = "my-task-exec-role"

  # Tasks IAM role
  create_tasks_iam_role = true
  tasks_iam_role_name   = "my-task-role"

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

## Examples

- [Complete ECS Task](../../examples/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 6.4   |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 6.4  |

## Modules

| Name                                                                                            | Source                  | Version |
| ----------------------------------------------------------------------------------------------- | ----------------------- | ------- |
| <a name="module_container_definition"></a> [container_definition](#module_container_definition) | ../container-definition | n/a     |

## Resources

| Name                                                                                                                                                          | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition)                               | resource    |
| [aws_iam_policy.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                            | resource    |
| [aws_iam_policy.tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                | resource    |
| [aws_iam_role.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                | resource    |
| [aws_iam_role.tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                    | resource    |
| [aws_iam_role_policy_attachment.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)            | resource    |
| [aws_iam_role_policy_attachment.task_exec_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_iam_role_policy_attachment.tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                | resource    |
| [aws_iam_role_policy_attachment.tasks_internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)       | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                 | data source |
| [aws_iam_policy_document.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                       | data source |
| [aws_iam_policy_document.task_exec_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                | data source |
| [aws_iam_policy_document.tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                           | data source |
| [aws_iam_policy_document.tasks_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                    | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition)                                             | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                   | data source |

## Inputs

See [variables.tf](./variables.tf) for a complete list and description of all configurable inputs.

## Outputs

See [outputs.tf](./outputs.tf) for a complete list and description of all outputs.

<!-- END_TF_DOCS -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/LICENSE).
