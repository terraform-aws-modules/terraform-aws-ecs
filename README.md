# terraform-aws-ecs
Terraform module which creates AWS ECS resources

These types of resources are supported:

* [ECS](https://www.terraform.io/docs/providers/aws/r/ecs_cluster.html)

Usage
-----

AWS ECS needs infrastructure like VPC and Subnets to be able to work. It is possible to use the default VPC in AWS but it's much neater to create a new one. For more information on how to do this see the example of <https://github.com/terraform-aws-modules/terraform-aws-vpc>.

```hcl
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  name = "my-ecs"
}
```

Conditional creation
--------------------

Sometimes you need to have a way to create ECS resources conditionally but Terraform does not allow to use `count` inside `module` block, so the solution is to specify argument `create_ecs`.

```hcl
# ECS cluster will not be created
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  create_ecs = false
  # ... omitted
}
```

License
-------

Apache 2 Licensed. See LICENSE for full details.
