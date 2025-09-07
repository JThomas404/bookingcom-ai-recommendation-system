module "storage" {
  source = "./modules/storage"

  project_prefix = var.project_prefix
  environment    = var.environment
  aws_region     = var.aws_region
  tags           = var.tags
}

module "compute" {
  source     = "./modules/compute"
  depends_on = [module.storage]

  project_prefix       = var.project_prefix
  environment          = var.environment
  aws_region           = var.aws_region
  dynamodb_table_names = module.storage.dynamodb-table-names
  s3_bucket_names      = module.storage.s3-bucket-names
  kms_key_arn          = module.storage.kms-key-arn
  tags                 = var.tags
}

module "frontend" {
  source = "./modules/frontend"

  website_bucket_regional_domain_name = module.storage.website-regional-domain-name
  website_bucket_name                 = module.storage.s3-bucket-names.website
  project_prefix                      = var.project_prefix
  environment                         = var.environment
  tags                                = var.tags
}
