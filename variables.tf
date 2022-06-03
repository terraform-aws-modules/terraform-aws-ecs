variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Cluster
################################################################################

variable "cluster_name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

variable "cluster_configuration" {
  description = "The execute command configuration for the cluster"
  type        = any
  default     = {}
}

variable "cluster_settings" {
  description = "Configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster"
  type        = map(string)
  default = {
    name  = "containerInsights"
    value = "enabled"
  }
}

################################################################################
# Cluster Capacity Providers
################################################################################

variable "cluster_capacity_providers" {
  description = "The capacity providers to use for the cluster"
  type        = any
  default     = {}
}

################################################################################
# Capacity Provider
################################################################################

variable "capacity_providers" {
  description = "Map of capacity provider definitons to create"
  type        = any
  default     = {}
}
