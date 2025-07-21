# ECS Container Definition

Configuration in this directory creates:

- ECS container definition

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.4 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | >= 2.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_container_definition"></a> [ecs\_container\_definition](#module\_ecs\_container\_definition) | ../../modules/container-definition | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.container_definition_json](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of CloudWatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of CloudWatch log group created |
| <a name="output_container_definition"></a> [container\_definition](#output\_container\_definition) | Container definition |
| <a name="output_container_definition_json"></a> [container\_definition\_json](#output\_container\_definition\_json) | Container definition |
<!-- END_TF_DOCS -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/LICENSE).
