variable "cluster_id" {
  description = "The ECS cluster ID"
  type        = string
}

variable "cluster_name" {
  description = "The ECS cluster name"
  type        = string
}

variable "service" {
  description = "The name of the service in the ECS cluster"
  type        = string
}

variable "region" {
  description = "Region to be propogated"
  type        = string
}
