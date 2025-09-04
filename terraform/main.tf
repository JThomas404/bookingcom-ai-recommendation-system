module "storage" {
  source = "./modules/storage"

  project_prefix = var.project_prefix
  environment    = var.environment
  aws_region     = var.aws_region

  tags = {
    Project     = var.project_prefix
    Environment = var.environment
  }
}

module "compute" {
  source = "./modules/compute"

  project_prefix       = var.project_prefix
  environment          = var.environment
  aws_region           = var.aws_region
  dynamodb_table_names = module.storage.dynamodb-table-names
  s3_bucket_names      = module.storage.s3-bucket-names
  kms_key_arn          = module.storage.kms-key-arn

  tags = {
    Project     = var.project_prefix
    Environment = var.environment
  }
}

