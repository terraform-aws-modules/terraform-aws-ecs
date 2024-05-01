################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = module.ecs_cluster.arn
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = module.ecs_cluster.id
}

output "cluster_name" {
  description = "Name that identifies the cluster"
  value       = module.ecs_cluster.name
}

output "cluster_capacity_providers" {
  description = "Map of cluster capacity providers attributes"
  value       = module.ecs_cluster.cluster_capacity_providers
}

output "cluster_autoscaling_capacity_providers" {
  description = "Map of capacity providers created and their attributes"
  value       = module.ecs_cluster.autoscaling_capacity_providers
}

################################################################################
# Private ECR Repository
################################################################################
output "private_ecr_repository_push_commands" {
  description = "Commands to push the awscli container image to the private ECR repository"
  value       = <<EOT
    aws ecr get-login-password --region ${local.region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com
    docker pull public.ecr.aws/aws-cli/aws-cli:latest
    docker tag public.ecr.aws/aws-cli/aws-cli:latest ${module.ecr.repository_url}:latest
    docker push ${module.ecr.repository_url}:latest
  EOT
}

################################################################################
# S3 bucket
################################################################################
output "s3_bucket_upload_command" {
  description = "Command to upload files to the example S3 bucket"
  value       = <<EOT
    aws --region ${local.region} s3 cp <local file> s3://${module.s3_bucket.s3_bucket_id}
  EOT
}

################################################################################
# Standalone Task Definition (w/o Service)
################################################################################

output "task_definition_run_task_command" {
  description = "awscli command to run the standalone task"
  value       = <<EOT
    aws ecs run-task --cluster ${module.ecs_cluster.name} \
      --task-definition ${module.ecs_task_definition.task_definition_family_revision} \
      --network-configuration "awsvpcConfiguration={subnets=[${join(",", module.vpc.intra_subnets)}],securityGroups=[${module.ecs_task_definition.security_group_id}]}" \
      --region ${local.region}
  EOT
}
