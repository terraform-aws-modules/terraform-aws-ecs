variable "defaults" {
  description = "Map of default values which will be used for each item."
  type        = any
  default     = {}
}

variable "items" {
  description = "Map of objects. Each object represents one item."
  type        = any
  default     = {}
}
