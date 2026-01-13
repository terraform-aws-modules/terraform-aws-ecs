# ECS Clusters w/ Fargate

Configuration in this directory creates:

- ECS cluster using Fargate (on-demand and spot) capacity providers
- Example ECS service that utilizes
  - AWS Firelens using FluentBit sidecar container definition
  - Service connect configuration
  - Load balancer target group attachment
  - Security group for access to the example service

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

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.28 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_express_service"></a> [ecs\_express\_service](#module\_ecs\_express\_service) | ../../modules/express-service | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_current_deployment"></a> [current\_deployment](#output\_current\_deployment) | Details about the current deployment |
| <a name="output_execution_iam_role_arn"></a> [execution\_iam\_role\_arn](#output\_execution\_iam\_role\_arn) | Task execution IAM role ARN |
| <a name="output_execution_iam_role_name"></a> [execution\_iam\_role\_name](#output\_execution\_iam\_role\_name) | Task execution IAM role name |
| <a name="output_infrastructure_iam_role_arn"></a> [infrastructure\_iam\_role\_arn](#output\_infrastructure\_iam\_role\_arn) | Infrastructure IAM role ARN |
| <a name="output_infrastructure_iam_role_name"></a> [infrastructure\_iam\_role\_name](#output\_infrastructure\_iam\_role\_name) | Infrastructure IAM role name |
| <a name="output_ingress_paths"></a> [ingress\_paths](#output\_ingress\_paths) | List of ingress paths associated with the service |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Amazon Resource Name (ARN) of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
| <a name="output_service_arn"></a> [service\_arn](#output\_service\_arn) | ARN of the ECS Express Service |
| <a name="output_service_revision_arn"></a> [service\_revision\_arn](#output\_service\_revision\_arn) | ARN of the ECS Express Service revision |
| <a name="output_service_url"></a> [service\_url](#output\_service\_url) | Public URL of the ECS Express Service |
| <a name="output_task_iam_role_arn"></a> [task\_iam\_role\_arn](#output\_task\_iam\_role\_arn) | Task IAM role ARN |
| <a name="output_task_iam_role_name"></a> [task\_iam\_role\_name](#output\_task\_iam\_role\_name) | Task IAM role name |
<!-- END_TF_DOCS -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/LICENSE).
