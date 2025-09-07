variable "website_bucket_regional_domain_name" {
  type        = string
  description = "Regional domain name of the website S3 bucket"
}

variable "website_bucket_name" {
  type        = string
  description = "Name of the website S3 bucket"
}

variable "project_prefix" {
  type        = string
  description = "Project prefix for resource naming"
}

variable "environment" {
  type        = string
  description = "Environment (dev/stage/prod)"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to resources"
}


