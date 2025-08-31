variable "project_name" {
  type    = string
  default = "Booking.com Recommendation System"
}

variable "project_prefix" {
  type    = string
  default = "bkr"
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
  type = map(string)
  default = {
    Project     = "bkr"
    Environment = "dev"
  }
}
