module "s3" {
  source         = "./modules/s3"
  project_prefix = var.project_prefix
}

module "iam" {
  source         = "./modules/iam"
  project_prefix = var.project_prefix
}

module "networking" {
  source         = "./modules/networking"
  project_prefix = var.project_prefix
}

module "rds" {
  source         = "./modules/rds"
  project_prefix = var.project_prefix
  db_subnet_group_name = module.networking.db_subnet_group_name
  aws_security_group = module.networking.aws_security_group
}

module "ec2" {
  source = "./modules/ec2"
  
  depends_on = [module.rds]
  vpc_id               = module.networking.vpc_id
  private_app_subnet_ids = module.networking.private_app_subnet_ids
  public_web_subnet_ids  = module.networking.public_web_subnet_ids

  private_app_sg_id = module.networking.private_app_sg_id
  public_web_sg_id  = module.networking.public_web_sg_id
  internal_lb_sg_id = module.networking.internal_lb_sg_id
  public_lb_sg_id   = module.networking.public_lb_sg_id
  

  aws_iam_instance_profile = module.iam.aws_iam_instance_profile

  project_prefix = var.project_prefix
}

