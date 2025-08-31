resource "aws_kms_key" "bkr-kms-key" {
  description         = "KMS key for ${var.project_prefix}-${var.environment}"
  enable_key_rotation = true

  tags = var.tags
}

resource "aws_kms_alias" "bkr-kms-alias" {
  name          = "alias/${var.project_prefix}-${var.environment}-key"
  target_key_id = aws_kms_key.bkr-kms-key.id
}

resource "random_id" "bkr-s3-bucket-suffix" {
  byte_length = 4
}

# S3 Bucket for Datasets
resource "aws_s3_bucket" "bkr-datasets-s3-bucket" {
  bucket        = "${var.project_prefix}-datasets-${random_id.bkr-s3-bucket-suffix.hex}"
  force_destroy = true

  tags = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bkr-datasets-s3-bucket-sse" {
  bucket = aws_s3_bucket.bkr-datasets-s3-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bkr-kms-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "bkr-s3-bucket-versioning" {
  bucket = aws_s3_bucket.bkr-datasets-s3-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bkr-datasets-web-access-block" {
  bucket = aws_s3_bucket.bkr-datasets-s3-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket for Artefacts
resource "aws_s3_bucket" "bkr-artefacts-s3-bucket" {
  bucket        = "${var.project_prefix}-artefacts-${random_id.bkr-s3-bucket-suffix.hex}"
  force_destroy = true

  tags = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bkr-artefacts-s3-bucket-sse" {
  bucket = aws_s3_bucket.bkr-artefacts-s3-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bkr-kms-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "bkr-artefacts-s3-bucket-versioning" {
  bucket = aws_s3_bucket.bkr-artefacts-s3-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bkr-artefacts-web-access-block" {
  bucket = aws_s3_bucket.bkr-artefacts-s3-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB Table for Hotels
resource "aws_dynamodb_table" "bkr-hotels-dynamodb-table" {
  name         = "${var.project_prefix}-${var.environment}-hotels"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "hotel_id"

  attribute {
    name = "hotel_id"
    type = "S"
  }
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.bkr-kms-key.arn
  }
}

# DynamoDB Table for User Interactions
resource "aws_dynamodb_table" "bkr-user-interactions-dynamodb-table" {
  name         = "${var.project_prefix}-${var.environment}-user-interactions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.bkr-kms-key.arn
  }
}

# DynamoDB Table for Experiment Configurations
resource "aws_dynamodb_table" "bkr-experiment-config-dynamodb-table" {
  name         = "${var.project_prefix}-${var.environment}-experiment-config"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "route"

  attribute {
    name = "route"
    type = "S"
  }
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.bkr-kms-key.arn
  }
}
