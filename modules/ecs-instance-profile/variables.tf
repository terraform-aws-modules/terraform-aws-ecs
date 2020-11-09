variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "include_ssm" {
  description = "Whether to include policies needed for AmazonSSM"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to instance profile role"
  type        = map(string)
  default     = {}
}
