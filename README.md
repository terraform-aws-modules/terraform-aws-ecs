# AWS Elastic Container Service (ECS) Terraform module

Terraform module which creates ECS resources on AWS.

This module focuses purely on ECS and nothing else. Therefore only these resources can be created with this module:

* [ECS](https://www.terraform.io/docs/providers/aws/r/ecs_cluster.html)
* [IAM](https://www.terraform.io/docs/providers/aws/r/iam_instance_profile.html)

However, having said the above to have a proper ECS cluster up and running multiple resources are needed. In most cases creating these resources is heavily opinionated and or context-bound. That is why this module does not create these resources. But you still need them to have a production ready environment. Therefore the example area shows how to create everything needed for a production environment.

## Usage

```hcl
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  name = "my-ecs"
}
```

## Conditional creation

Sometimes you need to have a way to create ECS resources conditionally but Terraform does not allow to use `count` inside `module` block, so the solution is to specify argument `create_ecs`.

```hcl
# ECS cluster will not be created
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  create_ecs = false
  # ... omitted
}
```

## Examples

* [Complete ECS](https://github.com/terraform-aws-modules/terraform-aws-ecs/tree/master/examples/complete-ecs)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| create\_ecs | Controls if ECS should be created | string | `"true"` | no |
| name | Name to be used on all the resources as identifier, also the name of the ECS cluster | string | n/a | yes |
| tags | A map of tags to add to ECS Cluster | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| this\_ecs\_cluster\_arn |  |
| this\_ecs\_cluster\_id |  |
| this\_ecs\_cluster\_name | The name of the ECS cluster |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module managed by [Armin Coralic](https://github.com/arminc), [Anton Babenko](https://github.com/antonbabenko) and [other awesome contributors](https://github.com/terraform-aws-modules/terraform-aws-ecs/graphs/contributors).

## License

Apache 2 Licensed. See LICENSE for full details.
