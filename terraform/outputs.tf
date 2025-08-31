output "kms-key-arn" {
  description = "ARN of the KMS key"
  value       = module.storage.kms-key-arn
}

output "s3-bucket-names" {
  description = "Names of the S3 buckets"
  value = {
    datasets  = module.storage.s3-bucket-names.datasets
    artefacts = module.storage.s3-bucket-names.artefacts
  }
}

output "dynamodb-table-names" {
  description = "Names of the DynamoDB Tables"
  value       = module.storage.dynamodb-table-names
}

output "api_url" {
  description = "API Gateway URL for testing"
  value       = module.compute.api_gateway_invoke_url
}
