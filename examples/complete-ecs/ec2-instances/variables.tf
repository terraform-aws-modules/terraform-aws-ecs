variable "environment" {
  description = "Name of the Environment, for example dev"
  default     = "dev"
}

variable "ecs_cluster" {
  description = "Name of the ECS cluster, name to be used on all the resources as identifier"
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in"
  type        = "list"
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the launch configuration"
  type        = "list"
}

# ASG
variable "max_size" {
  description = "The maximum size of the auto scale group"
  default     = 1
}

variable "min_size" {
  description = "The minimum size of the auto scale group"
  default     = 0
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  default     = 1
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  default     = "10m"
}

variable "ec2_profile" {}
