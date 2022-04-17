variable "create_ecs" {
  description = "Controls if ECS should be created"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name to be used on all the resources as identifier, also the name of the ECS cluster"
  type        = string
  default     = null
}

variable "capacity_providers" {
  description = "List of short names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE_SPOT."
  type        = list(string)
  default     = []
}

variable "default_capacity_provider_strategy" {
  description = "The capacity provider strategy to use by default for the cluster. Can be one or more."
  type        = list(map(any))
  default     = []
}

variable "container_insights" {
  description = "Controls if ECS Cluster has container insights enabled"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to ECS Cluster"
  type        = map(string)
  default     = {}
}

variable "configuration" {
  description = "Define a dynamic configuration block for the execute-command functionality at cluster level. Valid values for logging (if specified) are: NONE, DEFAULT, OVERRIDE. If OVERRIDE is specified then the cloudwatch group name or the S3 bucket name is mandatory"
  type = object({
    kms_key_id                     = string
    logging                        = string
    cloud_watch_encryption_enabled = bool
    cloud_watch_log_group_name     = string
    s3_bucket_name                 = string
    s3_bucket_encryption_enabled   = bool
    s3_key_prefix                  = string

  })
  default = {
    logging                        = "NONE"
    kms_key_id                     = null
    cloud_watch_encryption_enabled = null
    cloud_watch_log_group_name     = null
    s3_bucket_name                 = null
    s3_bucket_encryption_enabled   = null
    s3_key_prefix                  = null
  }
}
