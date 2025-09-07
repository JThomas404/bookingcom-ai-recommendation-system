output "kms-key-arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.bkr-kms-key.arn
}

output "s3-bucket-names" {
  description = "Names of the S3 buckets"
  value = {
    datasets  = aws_s3_bucket.bkr-buckets["datasets"].bucket
    artefacts = aws_s3_bucket.bkr-buckets["artefacts"].bucket
    website   = aws_s3_bucket.bkr-buckets["website"].bucket
  }
}

output "website-regional-domain-name" {
  description = "Regional domain name of the website S3 bucket"
  value       = aws_s3_bucket.bkr-buckets["website"].bucket_regional_domain_name
}

output "dynamodb-table-names" {
  description = "Names of the DynamoDB Tables"
  value = {
    hotels            = aws_dynamodb_table.bkr-hotels-dynamodb-table.name
    user_interactions = aws_dynamodb_table.bkr-user-interactions-dynamodb-table.name
    experiment_config = aws_dynamodb_table.bkr-experiment-config-dynamodb-table.name
  }
}
