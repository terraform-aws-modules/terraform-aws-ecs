# AWS Elastic Container Service (ECS) Terraform module

Terraform module which creates ECS resources on AWS.

This module focuses purely on ECS and nothing else. Therefore only these resources can be created with this module:

- [ECS](https://www.terraform.io/docs/providers/aws/r/ecs_cluster.html)
- [IAM](https://www.terraform.io/docs/providers/aws/r/iam_instance_profile.html)

However, having said the above to have a proper ECS cluster up and running multiple resources are needed. In most cases creating these resources is heavily opinionated and or context-bound. That is why this module does not create these resources. But you still need them to have a production ready environment. Therefore the example area shows how to create everything needed for a production environment.

## Usage

```hcl
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  name = "my-ecs"

  container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
    }
  ]

  tags = {
    Environment = "Development"
  }
}
```

## Conditional creation

Sometimes you need to have a way to create ECS resources conditionally but Terraform does not allow to use `count` inside `module` block, so the solution is to specify argument `create_ecs`.

```hcl
# ECS cluster will not be created
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 2.0"

  create_ecs = false
  # ... omitted
}
```

## Examples

- [Complete ECS](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/complete-ecs)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.48 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.48 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity_providers"></a> [capacity\_providers](#input\_capacity\_providers) | List of short names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE\_SPOT. | `list(string)` | `[]` | no |
| <a name="input_container_insights"></a> [container\_insights](#input\_container\_insights) | Controls if ECS Cluster has container insights enabled | `bool` | `false` | no |
| <a name="input_create_ecs"></a> [create\_ecs](#input\_create\_ecs) | Controls if ECS should be created | `bool` | `true` | no |
| <a name="input_default_capacity_provider_strategy"></a> [default\_capacity\_provider\_strategy](#input\_default\_capacity\_provider\_strategy) | The capacity provider strategy to use by default for the cluster. Can be one or more. | `list(map(any))` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all the resources as identifier, also the name of the ECS cluster | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to ECS Cluster | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | ARN of the ECS Cluster |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | ID of the ECS Cluster |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | The name of the ECS cluster |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Anton Babenko](https://github.com/antonbabenko) with help from [these awesome contributors](https://github.com/terraform-aws-modules/terraform-aws-ecs/graphs/contributors).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/LICENSE) for full details.
