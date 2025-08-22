# Terraform AWS ECS Task Module Wrapper

Configuration in this directory creates ECS task definition resources in various combinations.

This module is a wrapper over the [task](../../modules/task/) module, which allows managing several task resources in one place.

## Usage

```hcl
module "ecs_task_wrapper" {
  source = "terraform-aws-modules/ecs/aws//wrappers/task"

  defaults = {
    create_task_exec_iam_role = true
    create_tasks_iam_role     = true
  }

  items = {
    task1 = {
      name = "my-task-1"
      container_definitions = {
        app = {
          image = "nginx:latest"
        }
      }
    }
    task2 = {
      name = "my-task-2"
      container_definitions = {
        app = {
          image = "httpd:latest"
        }
      }
    }
  }
}
```

## Examples

See the [examples](../../examples/) directory for a complete example.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 6.4   |

## Providers

No providers.

## Modules

| Name                                                     | Source             | Version |
| -------------------------------------------------------- | ------------------ | ------- |
| <a name="module_wrapper"></a> [wrapper](#module_wrapper) | ../../modules/task | n/a     |

## Resources

No resources.

## Inputs

| Name                                                      | Description                                             | Type  | Default | Required |
| --------------------------------------------------------- | ------------------------------------------------------- | ----- | ------- | :------: |
| <a name="input_defaults"></a> [defaults](#input_defaults) | Map of default values which will be used for each item. | `any` | `{}`    |    no    |
| <a name="input_items"></a> [items](#input_items)          | Map of objects. Each object represents one item.        | `any` | `{}`    |    no    |

## Outputs

| Name                                                     | Description                  |
| -------------------------------------------------------- | ---------------------------- |
| <a name="output_wrapper"></a> [wrapper](#output_wrapper) | Map of outputs of a wrapper. |

<!-- END_TF_DOCS -->
