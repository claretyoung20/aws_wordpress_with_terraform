provider "aws" {
}

module "network" {
  source = "./modules/network"
  environment = var.environment
  availability_zones = var.availability_zones
  vpc_cidr_block = var.vpc_cidr_block
  my_ip = var.my_ip
  public_route_table_cidr_block = var.public_route_table_cidr_block
  public_subnet_AZ1_cidr_block = var.public_subnet_AZ1_cidr_block
  public_subnet_AZ2_cidr_block = var.public_subnet_AZ2_cidr_block
  private_app_subnet_AZ1_cidr_block = var.private_app_subnet_AZ1_cidr_block
  private_data_subnet_AZ1_cidr_block = var.private_data_subnet_AZ1_cidr_block
  private_app_subnet_AZ2_cidr_block = var.private_app_subnet_AZ2_cidr_block
  private_data_subnet_AZ2_cidr_block = var.private_data_subnet_AZ2_cidr_block
  public_cidr_block =  var.public_cidr_block
}

module "database" {
  source = "./modules/rds"
  environment = var.environment
  db_name = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  subnet_ids = [module.network.private_data_subnet_AZ1.id, module.network.private_data_subnet_AZ2.id]
  availability_zone = var.availability_zones[0]
  vpc_security_group_ids = [module.network.database_security_group.id] 

}

module "efs" {
  source = "./modules/efs"
  environment = var.environment
  private_data_subnet_AZ1_id = module.network.private_data_subnet_AZ1.id 
  private_data_subnet_AZ2_id = module.network.private_data_subnet_AZ2.id 
  efs_sec_groups = [module.network.efs_security_group.id]
}

module "ec2" {
  source = "./modules/ec2"
  environment = var.environment
  public_key = var.public_key
  custom_ami_id = var.custom_ami_id
  web_server_groups = [module.network.webserver_security_group.id] 
}

module "acm" {
  source = "./modules/acm"
  environment = var.environment
  domain_name = var.domain_name
  domain_alt_name = var.domain_alt_name
}

module "loadbalancer" {
  source = "./modules/loadbalancer"
  environment = var.environment
  vpc_id = module.network.vpc.id 
  alb_subnets = [module.network.public_subnet_AZ1.id, module.network.public_subnet_AZ2.id] 
  alb_sec_group = [module.network.alb_security_group.id]
  vpc_zone_identifiers = [module.network.private_app_subnet_AZ1.id,module.network.private_app_subnet_AZ2.id]
  launch_template_id = module.ec2.template.id
  cert_arn = module.acm.acm_cert.arn
}

module "route53" {
  source = "./modules/route53"
  environment = var.environment
  domain_name = var.domain_name
  domain_alt_name =  var.domain_alt_name
  alb_dns_name = module.loadbalancer.lb.dns_name
  alb_zone_id = module.loadbalancer.lb.zone_id 
  domain_validation_options = module.acm.acm_cert.domain_validation_options 
}

