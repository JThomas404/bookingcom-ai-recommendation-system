variable "project_prefix" {
  type        = string
  default     = "bkr"
  description = "Project prefix for resource naming"

  validation {
    condition     = can(regex("^[a-z]{2,4}$", var.project_prefix))
    error_message = "Project prefix must be 2-4 lowercase letters."
  }
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "tags" {
  type    = map(string)
  default = {}
}
