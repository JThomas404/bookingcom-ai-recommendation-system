output "kms-key-arn" {
  description = "ARN of the KMS key"
  value       = module.storage.kms-key-arn
}

output "s3-bucket-names" {
  description = "Names of the S3 buckets"
  value       = module.storage.s3-bucket-names
}

output "website-regional-domain-name" {
  description = "Regional domain name of the website S3 bucket"
  value       = module.storage.website-regional-domain-name
}

output "dynamodb-table-names" {
  description = "Names of the DynamoDB tables"
  value       = module.storage.dynamodb-table-names
}

output "api-url" {
  description = "API Gateway invoke URL"
  value       = module.compute.api_gateway_invoke_url
}

output "cloudfront-domain-name" {
  description = "CloudFront distribution domain name"
  value       = module.frontend.cloudfront-domain-name
}
