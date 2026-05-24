module "networking" {
  source = "./modules/networking"
}

module "database" {
  source               = "./modules/database"
  private_subnet_ids   = module.networking.private_subnet_ids
  db_security_group_id = module.networking.db_security_group_id
  db_password          = var.db_password
}

module "compute" {
  source            = "./modules/compute"
  subnet_id         = module.networking.public_subnet_id
  security_group_id = module.networking.security_group_id
  db_endpoint       = module.database.db_endpoint
}