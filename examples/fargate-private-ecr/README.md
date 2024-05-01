# ECS Cluster w/ Fargate and private network access

The configuration in this directory creates:

- an ECS cluster using Fargate (on-demand and spot) capacity providers
- an example ECS standalone task that utilizes:
  - VPC endpoints with a tight policy for the S3 Gateway endpoint
  - a private ECR repository to pull container images from
  - an S3 bucket to display its contents

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

The example output provides the commands to:
- pull the container image for the AWS CLI from the Amazon ECR Public Gallery and push it to a private ECR repository from where the ECS task executor will be able to pull it
- upload a test file to the S3 bucket whose contents the ECS task tries to list
- run the standalone task manually

Note that this example may create resources which will incur monetary charges on your AWS bill. Run `terraform destroy` when you no longer need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.66.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.66.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr"></a> [ecr](#module\_ecr) | terraform-aws-modules/ecr/aws | ~> 2.2 |
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | ../../modules/cluster | n/a |
| <a name="module_ecs_task_definition"></a> [ecs\_task\_definition](#module\_ecs\_task\_definition) | ../../modules/service | n/a |
| <a name="module_kms_bucket"></a> [kms\_bucket](#module\_kms\_bucket) | terraform-aws-modules/kms/aws | ~> 2.2 |
| <a name="module_kms_cloudwatch"></a> [kms\_cloudwatch](#module\_kms\_cloudwatch) | terraform-aws-modules/kms/aws | ~> 2.2 |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 4.1 |
| <a name="module_security_group_vpc_endpoint_interface"></a> [security\_group\_vpc\_endpoint\_interface](#module\_security\_group\_vpc\_endpoint\_interface) | terraform-aws-modules/security-group/aws | ~> 5.1 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | ~> 5.7 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN that identifies the cluster |
| <a name="output_cluster_autoscaling_capacity_providers"></a> [cluster\_autoscaling\_capacity\_providers](#output\_cluster\_autoscaling\_capacity\_providers) | Map of capacity providers created and their attributes |
| <a name="output_cluster_capacity_providers"></a> [cluster\_capacity\_providers](#output\_cluster\_capacity\_providers) | Map of cluster capacity providers attributes |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID that identifies the cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name that identifies the cluster |
| <a name="output_private_ecr_repository_push_commands"></a> [private\_ecr\_repository\_push\_commands](#output\_private\_ecr\_repository\_push\_commands) | Commands to push the awscli container image to the private ECR repository |
| <a name="output_s3_bucket_upload_command"></a> [s3\_bucket\_upload\_command](#output\_s3\_bucket\_upload\_command) | Command to upload files to the example S3 bucket |
| <a name="output_task_definition_run_task_command"></a> [task\_definition\_run\_task\_command](#output\_task\_definition\_run\_task\_command) | awscli command to run the standalone task |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/LICENSE).
