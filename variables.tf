variable "create_ecs" {
  description = "Controls if ECS should be created"
  default     = true
}

variable "name" {
  description = "Name to be used on all the resources as identifier, also the name of the ECS cluster"
}

variable "tags" {
  description = "A map of tags to add to ECS Cluster"
  default     = {}
}

variable "capacity_providers" {
  description = "List of short names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE_SPOT."
  default     = []
}
