module "vpc-module" {
  source = "./modules/VPC-setups"
  vpc_env_prefix = var.env_prefix
  VPC_avail_zone = var.avail_zone

}


module "EC2-module" {
  source = "./modules/EC2-server"
  EC2_env_prefix = var.env_prefix
  EC2_avail_zone = var.avail_zone
  subnet-id-for-EC2 = module.vpc-module.my-main-subnet-output.id  #taking the value from the module above
  vpc_id-for-EC2 = module.vpc-module.my-main-vpc-output.id  # taken  the value from the module above #so the servers in the vpc can be associated weith the secuerity group
}






