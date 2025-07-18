data "aws_region" "current" {
  region = var.region
}


locals {
  is_not_windows = contains(["LINUX"], var.operating_system_family)

  service        = var.service != null ? "/${var.service}" : ""
  name           = var.name != null ? "/${var.name}" : ""
  log_group_name = try(coalesce(var.cloudwatch_log_group_name, "/aws/ecs${local.service}${local.name}"), "")

  # tflint-ignore: terraform_naming_convention
  logConfiguration = merge(
    { for k, v in {
      logDriver = "awslogs",
      options = {
        awslogs-region        = data.aws_region.current.region,
        awslogs-group         = try(aws_cloudwatch_log_group.this[0].name, ""),
        awslogs-stream-prefix = "ecs"
      },
    } : k => v if var.create_cloudwatch_log_group },
    { for k, v in var.logConfiguration : k => v if v != null }
  )

  # tflint-ignore: terraform_naming_convention
  linuxParameters = var.enable_execute_command ? merge({ "initProcessEnabled" : true }, var.linuxParameters) : merge({ "initProcessEnabled" : false }, var.linuxParameters)

  definition = {
    command                = var.command
    cpu                    = var.cpu
    dependsOn              = var.dependsOn
    disableNetworking      = local.is_not_windows ? var.disableNetworking : null
    dnsSearchDomains       = local.is_not_windows ? var.dnsSearchDomains : null
    dnsServers             = local.is_not_windows ? var.dnsServers : null
    dockerLabels           = var.dockerLabels
    dockerSecurityOptions  = var.dockerSecurityOptions
    entrypoint             = var.entrypoint
    environment            = var.environment
    environmentFiles       = var.environmentFiles
    essential              = var.essential
    extraHosts             = local.is_not_windows ? var.extraHosts : null
    firelensConfiguration  = var.firelensConfiguration != null ? { for k, v in var.firelensConfiguration : k => v if v != null } : null
    healthCheck            = var.healthCheck != null ? { for k, v in var.healthCheck : k => v if v != null } : null
    hostname               = var.hostname
    image                  = var.image
    interactive            = var.interactive
    links                  = local.is_not_windows ? var.links : null
    linuxParameters        = local.is_not_windows ? { for k, v in local.linuxParameters : k => v if v != null } : null
    logConfiguration       = local.logConfiguration
    memory                 = var.memory
    memoryReservation      = var.memoryReservation
    mountPoints            = var.mountPoints
    name                   = var.name
    portMappings           = var.portMappings != null ? [for p in var.portMappings : { for k, v in p : k => v if v != null }] : null
    privileged             = local.is_not_windows ? var.privileged : null
    pseudoTerminal         = var.pseudoTerminal
    readonlyRootFilesystem = local.is_not_windows ? var.readonlyRootFilesystem : null
    repositoryCredentials  = var.repositoryCredentials
    resourceRequirements   = var.resourceRequirements
    restartPolicy          = { for k, v in var.restartPolicy : k => v if v != null }
    secrets                = var.secrets
    startTimeout           = var.startTimeout
    stopTimeout            = var.stopTimeout
    systemControls         = var.systemControls
    ulimits                = local.is_not_windows ? var.ulimits : null
    user                   = local.is_not_windows ? var.user : null
    versionConsistency     = var.versionConsistency
    volumesFrom            = var.volumesFrom
    workingDirectory       = var.workingDirectory
  }

  # Strip out all null values, ECS API will provide defaults in place of null/empty values
  container_definition = { for k, v in local.definition : k => v if v != null }
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_cloudwatch_log_group && var.enable_cloudwatch_logging ? 1 : 0

  region = var.region

  name              = var.cloudwatch_log_group_use_name_prefix ? null : local.log_group_name
  name_prefix       = var.cloudwatch_log_group_use_name_prefix ? "${local.log_group_name}-" : null
  log_group_class   = var.cloudwatch_log_group_class
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = var.tags
}
