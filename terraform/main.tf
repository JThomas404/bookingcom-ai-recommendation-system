module "storage" {
  source = "./modules/storage"

  project_prefix = var.project_prefix
  environment    = var.environment
  aws_region     = var.aws_region
  tags           = var.tags
}

module "compute" {
  source = "./modules/compute"

  project_prefix       = var.project_prefix
  environment          = var.environment
  aws_region           = var.aws_region
  dynamodb_table_names = module.storage.dynamodb-table-names
  tags                 = var.tags
}

