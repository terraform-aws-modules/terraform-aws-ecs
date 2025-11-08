# This example demonstrates how to configure a Windows task to use gMSA

# 1. Dummy Secrets Manager Secret (The credential spec ARN is stored here)
resource "aws_secretsmanager_secret" "gmsa_secret" {
  name = "gmsa-credential-spec-example"
}

# 2. Container Definition using the updated module
module "app_container" {
  source = "../../modules/container-definition" # Relative path to the module you are modifying

  name      = "windows-app"
  image     = "mcr.microsoft.com/windows/servercore:ltsc2022"
  cpu       = 512
  memory    = 1024
  essential = true

  # IMPORTANT: The OS must be Windows for credentialSpecs to be valid
  # Note: The 'operating_system_family' variable must also be present in the module's HCL
  operating_system_family = "WINDOWS_SERVER_2022_CORE"

  # The new feature being demonstrated, using a known placeholder ARN
  credentialSpecs = [
    aws_secretsmanager_secret.gmsa_secret.arn
  ]
}

# 3. Dummy Task Execution Role (Required for a runnable Task Definition)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-gMSA-example-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# 4. Task Definition that uses the container
resource "aws_ecs_task_definition" "windows_task" {
  family                   = "windows-gmsa-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  # The container definition must be JSON encoded
  container_definitions = jsonencode([module.app_container.container_definition])

  runtime_platform {
    operating_system_family = "WINDOWS_SERVER_2022_CORE"
  }
}