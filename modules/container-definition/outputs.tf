################################################################################
# Container Definition
################################################################################

output "container_definition" {
  description = "Container definition"
  value       = local.container_definition
}

# ToDo - remove at next breaking change. Not worth it
output "container_definition_json" {
  description = "Container definition. NOTE: use `jsonencode([module.ecs_container_definition.container_definition])` instead of this output when passing into a Task Definition"
  value       = jsonencode(local.container_definition)
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
