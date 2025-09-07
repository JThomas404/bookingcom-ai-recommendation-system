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

variable "s3_bucket_names" {
  type = object({
    datasets  = string
    artefacts = string
    website   = string
  })
}

variable "tags" {
  type = map(string)
}

variable "kms_key_arn" {
  type = string
}
