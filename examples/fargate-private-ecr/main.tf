provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

locals {
  region = "eu-west-2"
  name   = "ex-${basename(path.cwd)}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecs"
  }
}

################################################################################
# Cluster
################################################################################

module "ecs_cluster" {
  source = "../../modules/cluster"

  cluster_name = local.name

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  cloudwatch_log_group_kms_key_id = module.kms_cloudwatch.key_arn

  tags = local.tags
}

################################################################################
# Standalone Task Definition (w/o Service)
################################################################################

module "ecs_task_definition" {
  source = "../../modules/service"

  # Service
  name        = "${local.name}-standalone"
  cluster_arn = module.ecs_cluster.arn

  # Task Definition
  volume = {
    ex-vol = {}
  }

  runtime_platform = {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  # Container definition(s)
  container_definitions = {
    al2023 = {
      image = "${module.ecr.repository_url}:latest"

      mount_points = [
        {
          sourceVolume  = "ex-vol",
          containerPath = "/var/www/ex-vol"
        }
      ]

      command    = ["aws --region ${local.region} s3 ls ${module.s3_bucket.s3_bucket_id}"]
      entrypoint = ["/usr/bin/sh", "-c"]
    }
  }

  subnet_ids = module.vpc.intra_subnets

  security_group_rules = {
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  propagate_tags = "TASK_DEFINITION"

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs = local.azs

  # Intra subnets are designed to have no Internet access via NAT Gateway.
  intra_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]

  tags = local.tags
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.7"

  vpc_id = module.vpc.vpc_id

  # Amazon ECS tasks hosted on Fargate using platform version 1.4.0 or later require both
  # Amazon ECR VPC endpoints (ecr.dkr and ecr.api) and the Amazon S3 gateway endpoints.
  endpoints = merge({
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.intra_route_table_ids
      policy          = data.aws_iam_policy_document.s3_endpoint.json
      tags = {
        "Name" = "${local.name}-s3"
      }
    }
    },
    {
      for service in toset(["ecr.api", "ecr.dkr", "ecs", "ecs-telemetry", "ecs-agent", "logs"]) :
      replace(service, ".", "_") =>
      {
        service             = service
        private_dns_enabled = true
        subnet_ids          = module.vpc.intra_subnets
        security_group_ids  = [module.security_group_vpc_endpoint_interface.security_group_id]
        tags = {
          "Name" = "${local.name}-${service}"
        }
      }
  })

  tags = local.tags
}

data "aws_iam_policy_document" "s3_endpoint" {
  # See https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html#ecr-minimum-s3-perms
  statement {
    sid = "AllowBucketAccessForECROperations"

    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#principals-and-not_principals
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::prod-${local.region}-starport-layer-bucket/*",
    ]
  }

  # See https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-s3.html#edit-vpc-endpoint-policy-s3
  statement {
    sid = "RestrictBucketAccessToIAMRole"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${module.s3_bucket.s3_bucket_arn}/*",
      module.s3_bucket.s3_bucket_arn,
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = [module.ecs_task_definition.tasks_iam_role_arn]
    }
  }
}

module "security_group_vpc_endpoint_interface" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = local.name
  description = "Security Group for VPC Endpoint Ingress"

  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = module.vpc.intra_subnets_cidr_blocks

  ingress_rules = ["https-443-tcp"]

  tags = local.tags
}

module "kms_cloudwatch" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 2.2"

  description = "CloudWatch log encryption"

  computed_aliases = {
    logs = {
      name = "${local.name}-cloudwatch"
    }
  }
  aliases_use_name_prefix = true

  # See: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html#cmk-permissions
  key_statements = [
    {
      sid = "CloudWatchLogs"

      actions = [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ]

      resources = [
        "*"
      ]

      principals = [
        {
          type        = "Service"
          identifiers = ["logs.${local.region}.amazonaws.com"]
        }
      ]

      conditions = [
        {
          test     = "ArnLike"
          variable = "kms:EncryptionContext:aws:logs:arn"
          values = [
            "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:*",
          ]
        }
      ]
    }
  ]

  tags = merge(
    {
      # This module doesn't create resource-specific "Name" tags as the "name" input variable is not present
      "Name" = local.name
    },
    local.tags,
  )
}

module "kms_bucket" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 2.2"

  description = "S3 encryption"

  computed_aliases = {
    s3 = {
      name = "${local.name}-s3"
    }
  }
  aliases_use_name_prefix = true

  # Grants
  grants = {
    ecs = {
      grantee_principal = module.ecs_task_definition.tasks_iam_role_arn
      operations = [
        "GenerateDataKey",
        "Decrypt",
        "Encrypt",
      ]
    }
  }

  tags = merge(
    {
      # This module doesn't create resource-specific "Name" tags as the "name" input variable is not present
      "Name" = local.name
    },
    local.tags,
  )
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1"

  bucket_prefix = "${local.name}-"
  force_destroy = true

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  # Bucket policy
  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket.json

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = module.kms_bucket.key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = merge(
    {
      # This module doesn't create resource-specific "Name" tags as the "name" input variable is not present
      "Name" = local.name
    },
    local.tags,
  )
}

data "aws_iam_policy_document" "bucket" {
  statement {
    sid = "RestrictBucketAccessToIAMRole"

    principals {
      type        = "AWS"
      identifiers = [module.ecs_task_definition.tasks_iam_role_arn]
    }

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${module.s3_bucket.s3_bucket_arn}/*",
      module.s3_bucket.s3_bucket_arn,
    ]
  }
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.2"

  repository_name = local.name

  repository_force_delete     = true
  create_lifecycle_policy     = false
  repository_read_access_arns = [module.ecs_task_definition.task_exec_iam_role_arn]

  tags = local.tags
}
