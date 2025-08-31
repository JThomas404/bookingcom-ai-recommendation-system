output "kms-key-arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.bkr-kms-key.arn
}

output "s3-bucket-names" {
  description = "Names of the S3 buckets"
  value = {
    datasets  = aws_s3_bucket.bkr-datasets-s3-bucket.id
    artefacts = aws_s3_bucket.bkr-artefacts-s3-bucket.id
  }
}

output "dynamodb-table-names" {
  description = "Names of the DynamoDB Tables"
  value = {
    hotels            = aws_dynamodb_table.bkr-hotels-dynamodb-table.name
    user_interactions = aws_dynamodb_table.bkr-user-interactions-dynamodb-table.name
    experiment_config = aws_dynamodb_table.bkr-experiment-config-dynamodb-table.name
  }
}
