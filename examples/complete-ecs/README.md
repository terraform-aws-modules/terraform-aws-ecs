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

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.48 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.48 |
| <a name="provider_template"></a> [template](#provider\_template) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_asg"></a> [asg](#module\_asg) | terraform-aws-modules/autoscaling/aws | ~> 4.0 |
| <a name="module_disabled_ecs"></a> [disabled\_ecs](#module\_disabled\_ecs) | ../../ |  |
| <a name="module_ec2_profile"></a> [ec2\_profile](#module\_ec2\_profile) | ../../modules/ecs-instance-profile |  |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ../../ |  |
| <a name="module_hello_world"></a> [hello\_world](#module\_hello\_world) | ./service-hello-world |  |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_capacity_provider.prov1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider) | resource |
| [aws_ami.amazon_linux_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [template_file.user_data](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
