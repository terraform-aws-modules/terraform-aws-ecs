provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-1"
  name   = "ex-${basename(path.cwd)}"

  container_name = "ecsdemo-frontend"
  container_port = 3000

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecs"
  }
}

################################################################################
# Service
################################################################################

module "ecs_container_definition" {
  source = "../../modules/container-definition"

  name = local.name

  command = ["/usr/sbin/apache2", "-D", "FOREGROUND"]
  cpu     = 512

  dependsOn = [{
    containerName = "fluent-bit"
    condition     = "START"
  }]
  disableNetworking = false
  dnsSearchDomains  = ["mydns.on.my.network"]
  dnsServers        = ["172.20.0.11"]
  dockerLabels = {
    "com.example.label" = "value"
  }
  dockerSecurityOptions = ["no-new-privileges"]
  entrypoint            = ["/usr/sbin/apache2", "-D", "FOREGROUND"]
  environment = [
    {
      name  = "ENV_VAR_1"
      value = "value1"
    },
    {
      name  = "ENV_VAR_2"
      value = "value2"
    }
  ]
  environmentFiles = [
    {
      type  = "s3"
      value = "s3://my-bucket/my-env-file.env"
    }
  ]
  essential = true
  firelensConfiguration = {
    type = "fluentbit"
  }
  healthCheck = {
    command = ["CMD-SHELL", "curl -f http://localhost:${local.container_port}/health || exit 1"]
  }
  image       = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
  interactive = false
  linuxParameters = {
    capabilities = {
      add = []
      drop = [
        "NET_RAW"
      ]
    }
  }
  enable_cloudwatch_logging = false
  logConfiguration = {
    logDriver = "awsfirelens"
    options = {
      Name                    = "firehose"
      region                  = local.region
      delivery_stream         = "my-stream"
      log-driver-buffer-limit = "2097152"
    }
  }
  memory            = 1024
  memoryReservation = 100
  mountPoints = [
    {
      sourceVolume  = "my-vol",
      containerPath = "/var/www/my-vol"
    },
    {
      sourceVolume  = "ebs-volume"
      containerPath = "/ebs/data"
    }
  ]
  portMappings = [
    {
      name          = local.container_name
      containerPort = local.container_port
      hostPort      = local.container_port
      protocol      = "tcp"
    }
  ]
  privileged     = false
  pseudoTerminal = false
  restartPolicy = {
    enabled              = true
    ignoredExitCodes     = [1]
    restartAttemptPeriod = 60
  }
  readonlyRootFilesystem = true
  repositoryCredentials = {
    credentialsParameter = "arn:aws:secretsmanager:eu-west-1:123456789012:secret:my-repo-creds"
  }
  resourceRequirements = [
    {
      type  = "GPU"
      value = "1"
    },
  ]
  secrets = [
    {
      name      = "SECRET_ENV_VAR"
      valueFrom = "arn:aws:ssm:eu-west-1:123456789012:parameter/my-secret-env-var"
    }
  ]
  startTimeout = 30
  stopTimeout  = 120
  systemControls = [
    {
      namespace = "network"
      value     = "ipv6"
    },
    {
      namespace = "net.core.somaxconn"
      value     = "1024"
    }
  ]
  ulimits = [
    {
      name      = "nofile"
      softLimit = 1024
      hardLimit = 2048
    }
  ]
  user               = "65534"
  versionConsistency = "disabled"
  volumesFrom = [{
    sourceContainer = "fluent-bit"
    readOnly        = false
  }]
  workingDirectory = "/var/www/html"

  tags = local.tags
}

module "ecs_container_definition_simple" {
  source = "../../modules/container-definition"

  image                  = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
  cpu                    = 256
  memory                 = 512
  essential              = true
  readonlyRootFilesystem = false
  portMappings = [{
    name          = "app"
    protocol      = "tcp"
    containerPort = 80
    hostPort      = 80
  }]
  restartPolicy = {
    enabled = false
  }

  tags = local.tags
}
