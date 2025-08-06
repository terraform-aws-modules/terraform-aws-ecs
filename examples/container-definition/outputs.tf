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

resource "null_resource" "container_definition_json" {
  triggers = {
    container_definition_json = timestamp()
  }

  provisioner "local-exec" {
    # Need the output pretty-printed and sorted for comparison
    command = "echo '${module.ecs_container_definition.container_definition_json}' | jq -S > ./definition.json"
  }
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
