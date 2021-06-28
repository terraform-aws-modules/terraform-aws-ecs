# Change Log

All notable changes to this project will be documented in this file.

<a name="unreleased"></a>
## [Unreleased]



<a name="v3.3.0"></a>
## [v3.3.0] - 2021-06-28

- fix: Complete ECS example (IAM role not configured in ASG) ([#45](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/45))


<a name="v3.2.0"></a>
## [v3.2.0] - 2021-06-20

- feat: Add GovCloud support ([#44](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/44))


<a name="v3.1.0"></a>
## [v3.1.0] - 2021-05-07

- chore: Fixed code in example ([#41](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/41))
- chore: update CI/CD to use stable `terraform-docs` release artifact and discoverable Apache2.0 license ([#40](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/40))


<a name="v3.0.0"></a>
## [v3.0.0] - 2021-04-26

- feat: Shorten outputs (removing this_) ([#39](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/39))


<a name="v2.9.0"></a>
## [v2.9.0] - 2021-04-11

- feat: Add this_iam_instance_profile_arn output ([#38](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/38))
- chore: update documentation and pin `terraform_docs` version to avoid future changes ([#36](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/36))
- fix: correct documentation based on update by `terraform_docs` ([#35](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/35))
- chore: add ci-cd workflow for pre-commit checks ([#34](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/34))


<a name="v2.8.0"></a>
## [v2.8.0] - 2021-02-20

- chore: update documentation based on latest `terraform-docs` which includes module and resource sections ([#33](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/33))


<a name="v2.7.0"></a>
## [v2.7.0] - 2021-01-30

- fix: Fixed no capacity providers with a weight value greater than 0 error message ([#30](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/30))


<a name="v2.6.0"></a>
## [v2.6.0] - 2021-01-26

- fix: Converting type of `default_capacity_provider_strategy` from map to list ([#28](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/28))


<a name="v2.5.0"></a>
## [v2.5.0] - 2020-11-09

- feat: Added capacity providers options to ECS cluster ([#25](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/25))
- feat: add tags to ECS instance profile role ([#21](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/21))


<a name="v2.4.0"></a>
## [v2.4.0] - 2020-10-06

- feat: Added IAM role id to outputs ([#13](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/13))


<a name="v2.3.0"></a>
## [v2.3.0] - 2020-06-29

- feat: Add container insights ([#10](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/10))


<a name="v2.2.0"></a>
## [v2.2.0] - 2020-06-23

- fix: make the example workable ([#23](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/23))


<a name="v2.1.0"></a>
## [v2.1.0] - 2020-06-23

- fix: Remove the dependency of hard coded region and availability zones ([#22](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/22))


<a name="v2.0.0"></a>
## [v2.0.0] - 2019-06-09

- Updated module to support Terraform 0.12 ([#8](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/8))
- Fixed formatting
- Updated Terraform 0.12


<a name="v1.4.0"></a>
## [v1.4.0] - 2019-06-09

- Added changelog


<a name="v1.3.0"></a>
## [v1.3.0] - 2019-03-08

- Add tag support for ECS module


<a name="v1.2.0"></a>
## [v1.2.0] - 2019-03-05

- Updated pre-commit
- Added cluster name to outputs


<a name="v1.1.0"></a>
## [v1.1.0] - 2019-01-22

- Run pre-commit -a
- Add ARN output to README
- Add arn output
- Fix typos


<a name="v1.0.0"></a>
## [v1.0.0] - 2018-05-20

- Updated README.md
- Added pre-commit hooks with docs
- Use this_ in the outputs
- Fix output when create cluster is false
- Move ec2-instances to main.tf in the example for easier reading
- Add link to examples from the readme
- Remove fixed versions from other dependencies
- Use _ instead of -in the resource name
- Call the resource 'this'
- Fix typo
- Remove version: need to be able to run examples using latest automatically
- Create only ECS resources nothing more
- Adding EC2 instances
- Update all to newest version
- Add infrastructure to the example
- Create ECS cluster


<a name="v0.0.1"></a>
## v0.0.1 - 2017-09-26

- Initial commit
- Initial commit


[Unreleased]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v3.3.0...HEAD
[v3.3.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v3.2.0...v3.3.0
[v3.2.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v3.1.0...v3.2.0
[v3.1.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v3.0.0...v3.1.0
[v3.0.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v2.9.0...v3.0.0
[v2.9.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v2.8.0...v2.9.0
[v2.8.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v2.7.0...v2.8.0
[v2.7.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v2.6.0...v2.7.0
[v2.6.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v2.5.0...v2.6.0
[v2.5.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v2.4.0...v2.5.0
[v2.4.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v2.3.0...v2.4.0
[v2.3.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v2.2.0...v2.3.0
[v2.2.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v2.1.0...v2.2.0
[v2.1.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v2.0.0...v2.1.0
[v2.0.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v1.4.0...v2.0.0
[v1.4.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v1.3.0...v1.4.0
[v1.3.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v1.2.0...v1.3.0
[v1.2.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v1.1.0...v1.2.0
[v1.1.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v1.0.0...v1.1.0
[v1.0.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v0.0.1...v1.0.0
