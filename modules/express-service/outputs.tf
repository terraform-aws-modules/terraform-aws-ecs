################################################################################
# Express Service
################################################################################

output "current_deployment" {
  description = "Details about the current deployment"
  value       = try(aws_ecs_express_gateway_service.this[0].current_deployment, null)
}

output "ingress_paths" {
  description = "List of ingress paths associated with the service"
  value       = try(aws_ecs_express_gateway_service.this[0].ingress_paths, null)
}

output "service_arn" {
  description = "ARN of the ECS Express Service"
  value       = try(aws_ecs_express_gateway_service.this[0].service_arn, null)
}

output "service_revision_arn" {
  description = "ARN of the ECS Express Service revision"
  value       = try(aws_ecs_express_gateway_service.this[0].service_revision_arn, null)
}

output "service_url" {
  description = "URL of the ECS Express Service"
  value       = "https://${try(aws_ecs_express_gateway_service.this[0].service_name, "")}.ecs.${local.region}.on.aws/"
}

################################################################################
# Security Group
################################################################################

output "security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = try(aws_security_group.this[0].arn, null)
}

output "security_group_id" {
  description = "ID of the security group"
  value       = try(aws_security_group.this[0].id, null)
}

################################################################################
# Execution IAM Role
################################################################################

output "execution_iam_role_name" {
  description = "Task execution IAM role name"
  value       = try(aws_iam_role.execution[0].name, null)
}

output "execution_iam_role_arn" {
  description = "Task execution IAM role ARN"
  value       = try(aws_iam_role.execution[0].arn, var.execution_iam_role_arn)
}

############################################################################################
# Infrastructure IAM Role
############################################################################################

output "infrastructure_iam_role_arn" {
  description = "Infrastructure IAM role ARN"
  value       = try(aws_iam_role.infrastructure[0].arn, null)
}

output "infrastructure_iam_role_name" {
  description = "Infrastructure IAM role name"
  value       = try(aws_iam_role.infrastructure[0].name, null)
}

################################################################################
# Task IAM Role
################################################################################

output "task_iam_role_name" {
  description = "Task IAM role name"
  value       = try(aws_iam_role.task[0].name, null)
}

output "task_iam_role_arn" {
  description = "Task IAM role ARN"
  value       = try(aws_iam_role.task[0].arn, var.task_iam_role_arn)
}

################################################################################
# CloudWatch Log Group
################################################################################

output "cloudwatch_log_group_name" {
  description = "Name of CloudWatch log group created"
  value       = try(aws_cloudwatch_log_group.this[0].name, null)
}

output "cloudwatch_log_group_arn" {
  description = "ARN of CloudWatch log group created"
  value       = try(aws_cloudwatch_log_group.this[0].arn, null)
}
