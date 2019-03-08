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
