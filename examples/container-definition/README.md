# ECS Container Definition

Configuration in this directory creates:

- ECS container definition

## Usage

To run this example you need to execute:

```bash
terraform init
terraform plan
terraform apply
```

Note that this example may create resources which will incur monetary charges on your AWS bill. Run `terraform destroy` when you no longer need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_container_definition"></a> [ecs\_container\_definition](#module\_ecs\_container\_definition) | ../../modules/container-definition | n/a |
| <a name="module_ecs_container_definition_simple"></a> [ecs\_container\_definition\_simple](#module\_ecs\_container\_definition\_simple) | ../../modules/container-definition | n/a |

## Resources

| Name | Type |
|------|------|
| [null_resource.container_definition_json](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.container_definition_json_simple](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_write_container_definition_to_file"></a> [write\_container\_definition\_to\_file](#input\_write\_container\_definition\_to\_file) | Determines whether the container definition JSON should be written to a file. Used for debugging and checking diffs | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of CloudWatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of CloudWatch log group created |
| <a name="output_container_definition"></a> [container\_definition](#output\_container\_definition) | Container definition |
| <a name="output_container_definition_json"></a> [container\_definition\_json](#output\_container\_definition\_json) | Container definition |
| <a name="output_container_definition_json_simple"></a> [container\_definition\_json\_simple](#output\_container\_definition\_json\_simple) | Container definition |
| <a name="output_container_definition_simple"></a> [container\_definition\_simple](#output\_container\_definition\_simple) | Container definition |
<!-- END_TF_DOCS -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/LICENSE).
