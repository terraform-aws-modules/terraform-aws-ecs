################################################################################
# Container Definition
################################################################################

output "container_definition" {
  description = "Container definition"
  value       = module.ecs_container_definition.container_definition
}

output "container_definition_json" {
  description = "Container definition"
  value       = module.ecs_container_definition.container_definition_json
}

resource "local_file" "container_definition_json" {
  content  = module.ecs_container_definition.container_definition_json
  filename = "${path.module}/definition.json"
}

################################################################################
# CloudWatch Log Group
################################################################################

output "cloudwatch_log_group_name" {
  description = "Name of CloudWatch log group created"
  value       = module.ecs_container_definition.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of CloudWatch log group created"
  value       = module.ecs_container_definition.cloudwatch_log_group_arn
}
