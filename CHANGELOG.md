# Changelog

All notable changes to this project will be documented in this file.

## [5.12.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.11.4...v5.12.0) (2024-11-29)


### Features

* Allow task exec IAM policy to have an IAM path ([#243](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/243)) ([c9dc889](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/c9dc889a4b081105fb7567ca12a2d32ac36caa29))


### Bug Fixes

* Update CI workflow versions to latest ([#236](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/236)) ([fd0f0ec](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/fd0f0ecd7fd3a85d8d738320d37a22644b5f129a))

## [5.11.4](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.11.3...v5.11.4) (2024-08-07)


### Bug Fixes

* Local `cluster_name` error when `var.cluster_arn` is empty ([#218](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/218)) ([42f11fe](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/42f11fe46b1f2a00125af0ee98813bff25d0bc46))

## [5.11.3](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.11.2...v5.11.3) (2024-07-05)


### Bug Fixes

* Add missing `pid_mode` to root module ([#204](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/204)) ([c9cab6f](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/c9cab6f005379e25ee91d17c7b8d4cb9d8ca9af8))

## [5.11.2](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.11.1...v5.11.2) (2024-05-31)


### Bug Fixes

* Make service, task, and task sets wait for their respective policy attachment to ensure permissions are available ([#201](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/201)) ([2033858](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/20338580482518fa086e90d9f74a54e8046fcb9a))

## [5.11.1](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.11.0...v5.11.1) (2024-04-10)


### Bug Fixes

* Add aws to required providers ([#181](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/181)) ([59fd4fa](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/59fd4fa7b34daede721a27ba7fda44acfca8de29))

## [5.11.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.10.1...v5.11.0) (2024-04-03)


### Features

* Allow configuring max_session_duration for the ECS Task Execution role ([#186](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/186)) ([1b8cad1](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/1b8cad10d2f414ecfdeb48e1dee73eccadefad1a))

## [5.10.1](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.10.0...v5.10.1) (2024-04-01)


### Bug Fixes

* Dynamic network configuration in service module for external deployments with awsvpc networkmode ([#185](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/185)) ([c817ed9](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/c817ed992ed75d73a54f69bf130c3730af8ba709)), closes [#184](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/184)

## [5.10.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.9.3...v5.10.0) (2024-03-12)


### Features

* Allow disabling service creation to support creating just a task definition ([#176](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/176)) ([94c992a](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/94c992aef62e6c8249acb1109b49a5cf98457288)), closes [#162](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/162)

## [5.9.3](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.9.2...v5.9.3) (2024-03-07)


### Bug Fixes

* Update CI workflow versions to remove deprecated runtime warnings ([#178](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/178)) ([a1fd9ef](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/a1fd9ef2199a0a5e851e4d131f8bca84d0723065))

### [5.9.2](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.9.1...v5.9.2) (2024-03-04)


### Bug Fixes

* Add missing `Name` tag to service security group ([#177](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/177)) ([b3600de](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/b3600def4e922e00483596fb84153ec82b77fc20))

### [5.9.1](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.9.0...v5.9.1) (2024-02-19)


### Bug Fixes

* Pass CloudWatch log group name from the service module to the container definition module ([#168](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/168)) ([9a7c9da](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/9a7c9da0fbe686bbe0f9c687986065c4655ba923))

## [5.9.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.8.1...v5.9.0) (2024-02-12)


### Features

* Add support for cluster and container definition custom CloudWatch log group names ([#160](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/160)) ([9a8c7d3](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/9a8c7d3cb799ec297d8ae1891616bc2872799ab7))

### [5.8.1](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.8.0...v5.8.1) (2024-02-12)


### Bug Fixes

* Allow `cluster_settings` to be list of maps instead of single map ([#157](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/157)) ([c32a657](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/c32a65786dbfb28bac8fbc9f60ff3a4ac06830d9))

## [5.8.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.7.4...v5.8.0) (2024-01-29)


### Features

* Add var service_tags ([#159](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/159)) ([1290240](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/1290240980647d391b49d417cb6d201d5620544c))

### [5.7.4](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.7.3...v5.7.4) (2023-12-21)


### Bug Fixes

* Adding a `health_check` generates a new task definition revision on every `terraform apply` ([#149](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/149)) ([492e323](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/492e323c82447fcaecaa818dc9c258daa923f254))

### [5.7.3](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.7.2...v5.7.3) (2023-11-27)


### Bug Fixes

* Bump MSV of AWS provider to support AppAutoscaling target tags ([#141](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/141)) ([eb7538a](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/eb7538ab30af1a3f10836f96e413385b8f8e2138))

### [5.7.2](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.7.1...v5.7.2) (2023-11-16)


### Bug Fixes

* Allow setting `linux_parameters` without inconsistent left/right error ([#136](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/136)) ([45a37ac](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/45a37aca96651bf541aedc9778c063e12e4c317a))

### [5.7.1](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.7.0...v5.7.1) (2023-11-16)


### Bug Fixes

* Add missing tag variable in autoscaling target resource ([#135](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/135)) ([5872445](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/58724455b3738f060de860f298ebc79f3b5d04e6))

## [5.7.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.6.0...v5.7.0) (2023-11-15)


### Features

* Add create option for container definition ([#133](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/133)) ([66642c8](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/66642c898988bf04b414c681d1ae4e5ecac08ba1))

## [5.6.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.5.0...v5.6.0) (2023-11-03)


### Features

* Add the external resource equivalents to the outputs as the fallback value ([#131](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/131)) ([e9d920b](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/e9d920b62779a4ea237cd560f66134b320df88c4))

## [5.5.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.4.0...v5.5.0) (2023-10-31)


### Features

* Replace dynamic DNS suffix resolution for trusted service endpoints with static `*.amazonaws.com` ([#125](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/125)) ([f84dc7d](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/f84dc7d29247a6e2a1012f30bc5e47deeb1df925))

## [5.4.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.3.0...v5.4.0) (2023-10-30)


### Features

* Add support for easily enabling ECS Exec support ([#127](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/127)) ([76acddb](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/76acddb0cc1649fa4b7a8338f0b6253b68bdeb8e))

## [5.3.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.2.2...v5.3.0) (2023-10-30)


### Features

* Add support for using container definition CloudWatch log group name as prefix ([#126](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/126)) ([cf4101e](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/cf4101ea7c4ca315f8f9958156b6dfe48c0c4f51))

### [5.2.2](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.2.1...v5.2.2) (2023-08-22)


### Bug Fixes

* Correct `wait_until_stable_timeout` variable type ([#110](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/110)) ([daa2c0e](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/daa2c0e8baf0c451c5dd0f614e53e3495ac54a64))

### [5.2.1](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.2.0...v5.2.1) (2023-07-27)


### Bug Fixes

* Add default values for attributes that are showing up in plans and causing unnecessary diffs ([#101](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/101)) ([6be5cc1](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/6be5cc1e01c55ebe44c9330e1e075aa013953f3d))

## [5.2.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.1.0...v5.2.0) (2023-06-05)


### Features

* Add support for setting placement constraints separately between service and task definition ([#93](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/93)) ([a111e5d](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/a111e5d38dca8b8743f8844e8aaa68568e1d737e))

## [5.1.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.0.2...v5.1.0) (2023-06-05)


### Features

* Add option to ignore `load_balancer` changes to ECS service ([#81](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/81)) ([24bd1d8](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/24bd1d8d48596743a7cc5e74b1943b76e7916a5c))

### [5.0.2](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.0.1...v5.0.2) (2023-06-03)


### Bug Fixes

* Missing field LogConfiguration.LogDriver error when enable_cloudwatch_logging is false ([#91](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/91)) ([8ca6fd4](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/8ca6fd4320441ed1f20d2c1c526ad034ab8dc0ac))

### [5.0.1](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v5.0.0...v5.0.1) (2023-04-26)


### Bug Fixes

* Ensure that launch type is not specified when a capacity provider strategy is set on a service ([#80](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/80)) ([873cccf](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/873cccf1ea23b87fec8bffe0a4825178f0b1cacf))

## [5.0.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v4.1.3...v5.0.0) (2023-04-21)


### ⚠ BREAKING CHANGES

* Add support for creating ECS service and container definition (#76)

### Features

* Add support for creating ECS service and container definition ([#76](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/76)) ([57244e6](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/57244e69abea685f7d45352abc994779b5f6d352))

### [4.1.3](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v4.1.2...v4.1.3) (2023-01-24)


### Bug Fixes

* Use a version for  to avoid GitHub API rate limiting on CI workflows ([#73](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/73)) ([fbff232](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/fbff232279bc5292a8469aa2a999ed08f4457011))

### [4.1.2](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v4.1.1...v4.1.2) (2022-11-07)


### Bug Fixes

* Update CI configuration files to use latest version ([#71](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/71)) ([2f68113](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/2f68113130c3a815a2d0b83af0f645d561c1fbe0))

### [4.1.1](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v4.1.0...v4.1.1) (2022-07-25)


### Bug Fixes

* Allow for both Fargate and EC2/Autoscaling capacity providers in same cluster ([#69](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/69)) ([9cb2b84](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/9cb2b84e5bb3983392c2d4c0e1f2879b42bbf9a7))

## [4.1.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v4.0.2...v4.1.0) (2022-06-29)


### Features

* Export cluster name since cluster ID is exporting the ARN ([#67](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/67)) ([8c9273f](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/8c9273ff625ca8897d27af7bcb9e5d177a3a45c4))

### [4.0.2](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v4.0.1...v4.0.2) (2022-06-20)


### Bug Fixes

* Complete example EC2 instance cluster joining issue ([#64](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/64)) ([81a7a56](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/81a7a560ab976c7c4b983355de4b97af3637734a))

### [4.0.1](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v4.0.0...v4.0.1) (2022-06-11)


### Bug Fixes

* Add empty map to `execute_command_configuration` to avoid plugin crash from interface conversion ([#62](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/62)) ([1669236](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/16692361dfa3bd1506cea3e893f484790bab5c8a))

## [4.0.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v3.5.0...v4.0.0) (2022-06-08)


### ⚠ BREAKING CHANGES

* Upgrade module to include capacity providers and bump minimum supported versions (#60)

### Features

* Upgrade module to include capacity providers and bump minimum supported versions ([#60](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/60)) ([7a41657](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/7a41657bd07d42b73757863266b6ea68710c36ce))

## [3.5.0](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v3.4.1...v3.5.0) (2022-03-18)


### Features

* Add aws_ecs_cluster_capacity_providers resource ([#55](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/55)) ([bff70b3](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/bff70b384a337ed0a5f2254c08cd937c7a4ba90c))

## [3.4.1](https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v3.4.0...v3.4.1) (2021-11-22)


### Bug Fixes

* update CI/CD process to enable auto-release workflow ([#51](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/51)) ([c9e282b](https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/c9e282b6a6d65c57ff29e34a0bed4c06ac1dbabd))

<a name="v3.4.0"></a>
## [v3.4.0] - 2021-09-07

- Drop support for Terraform 0.12
- feat: Add tags to aws_iam_instance_profile ([#49](https://github.com/terraform-aws-modules/terraform-aws-ecs/issues/49))


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


[Unreleased]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v3.4.0...HEAD
[v3.4.0]: https://github.com/terraform-aws-modules/terraform-aws-ecs/compare/v3.3.0...v3.4.0
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
