# Complete ECS

This example uses only verified Terraform modules to create all resources that are needed for an ECS cluster that is sufficient for staging or production environment.

While this example is still in the early stage there are other repositories that show how to create an ECS cluster:

* <https://github.com/anrim/terraform-aws-ecs>
* <https://github.com/arminc/terraform-ecs>
* <https://github.com/alex/ecs-terraform>
* <https://github.com/Capgemini/terraform-amazon-ecs>

## TODO

Things still needed in the example:

* AWS network infrastructure on what is created
* Full explanation on why certain resources are created
* Create EC2 instance specific SecurityGroup instead of using the default one from VPC module
* Push logs of default EC2 stuff (docker, ecs agent, etc...) to CloudWatch logs
* Add an example with ALB
* Add an example with NLB
* Add an example with ELB
* Create a Fargate example

## Usage

To run this example you need to execute:

```bash
terraform init
terraform plan
terraform apply
```

Note that this example may create resources which can cost money (AWS EC2 instances, for example). Run `terraform destroy` when you don't need these resources.

## Explanation

Current version creates an high-available VPC with instances that are attached to ECS. ECS tasks can be run on these instances but they are not exposed to anything.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| template | n/a |

## Inputs

No input.

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
