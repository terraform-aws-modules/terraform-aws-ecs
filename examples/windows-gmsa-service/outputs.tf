output "task_definition_arn" {
  description = "The ARN of the ECS Task Definition created with gMSA credentials."
  value       = aws_ecs_task_definition.windows_task.arn
}