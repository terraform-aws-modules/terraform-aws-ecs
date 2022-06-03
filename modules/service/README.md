# ECS Service Module

Configuration in this directory creates an ECS Service EKS Profile

⚠️ Module is under active development ⚠️

## TODO

- [ ] `aws_ecs_service` (one default, one with `ignore_changes` for things like `desired_count`)
- [ ] `aws_ecs_task_definition`
- [ ] `aws_ecs_task_set`
- [ ] `aws_appautoscaling_target` & `aws_appautoscaling_policy` (`for_each` over a shared map where each key = 1 target and 2 policies, 1 policy for scale up, 1 for scale down)
- [ ] Task role (`aws_iam_role`, `aws_iam_role_policy_attachment`, assume role `aws_iam_policy_document`)
- [ ] Task exectution role (`aws_iam_role`, `aws_iam_role_policy_attachment`, assume role `aws_iam_policy_document`)
- [ ] ECS CloudWatch events role (`aws_iam_role`, `aws_iam_role_policy_attachment`, assume role `aws_iam_policy_document`)

## Usage

```hcl
module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name       = "MyService"
  cluster_id = module.ecs.cluster_id

  # TODO

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### Logging

Please refer to https://github.com/aws-samples/amazon-ecs-firelens-examples for logging architectures for FireLens on Amazon ECS and AWS Fargate.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.6 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
