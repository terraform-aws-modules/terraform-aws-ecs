terraform {
  required_version = ">= 0.12.6, < 0.14"

  required_providers {
    aws      = ">= 2.0, < 4.0"
    template = "~> 2.0"
  }
}
