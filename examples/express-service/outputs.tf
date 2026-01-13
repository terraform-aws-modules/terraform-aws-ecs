################################################################################
# Express Service
################################################################################

output "current_deployment" {
  description = "Details about the current deployment"
  value       = module.ecs_express_service.current_deployment
}

output "ingress_paths" {
  description = "List of ingress paths associated with the service"
  value       = module.ecs_express_service.ingress_paths
}

output "service_arn" {
  description = "ARN of the ECS Express Service"
  value       = module.ecs_express_service.service_arn
}

output "service_revision_arn" {
  description = "ARN of the ECS Express Service revision"
  value       = module.ecs_express_service.service_revision_arn
}

output "service_url" {
  description = "Public URL of the ECS Express Service"
  value       = module.ecs_express_service.service_url
}

################################################################################
# Security Group
################################################################################

output "security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = module.ecs_express_service.security_group_arn
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.ecs_express_service.security_group_id
}

################################################################################
# Execution IAM Role
################################################################################

output "execution_iam_role_name" {
  description = "Task execution IAM role name"
  value       = module.ecs_express_service.execution_iam_role_name
}

output "execution_iam_role_arn" {
  description = "Task execution IAM role ARN"
  value       = module.ecs_express_service.execution_iam_role_arn
}

############################################################################################
# Infrastructure IAM Role
############################################################################################

output "infrastructure_iam_role_arn" {
  description = "Infrastructure IAM role ARN"
  value       = module.ecs_express_service.infrastructure_iam_role_arn
}

output "infrastructure_iam_role_name" {
  description = "Infrastructure IAM role name"
  value       = module.ecs_express_service.infrastructure_iam_role_name
}

################################################################################
# Task IAM Role
################################################################################

output "task_iam_role_name" {
  description = "Task IAM role name"
  value       = module.ecs_express_service.task_iam_role_name
}

output "task_iam_role_arn" {
  description = "Task IAM role ARN"
  value       = module.ecs_express_service.task_iam_role_arn
}

################################################################################
# CloudWatch Log Group
################################################################################

output "cloudwatch_log_group_name" {
  description = "Name of CloudWatch log group created"
  value       = module.ecs_express_service.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of CloudWatch log group created"
  value       = module.ecs_express_service.cloudwatch_log_group_arn
}
