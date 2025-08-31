variable "project_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "dynamodb_table_names" {
  type = map(string)
}

variable "tags" {
  type = map(string)
}
