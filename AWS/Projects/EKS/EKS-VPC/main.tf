
module "vpc-module" {
  source = "./modules/VPC"
  VPC_env_prefix = var.env_prefix
  VPC_avail_zone = var.avail_zone
}


module "EKS-module" {
  source = "./modules/EKS"
  EKS-VPC-ID = module.vpc-module.my-main-vpc-output.id
  EKS-Subnet-IDs = [module.vpc-module.my-main-subnet-output1.id,module.vpc-module.my-main-subnet-output2.id]
  EKS-SG =  module.EC2-module.module_EKS-SG.id
}


module "EC2-module" {
  source = "./modules/EC2"
  EC2_env_prefix = var.env_prefix
  EC2_avail_zone = var.avail_zone
  public_key_location = var.SSH_public_key_location
  subnet-id-for-EC2 = module.vpc-module.my-main-subnet-output1.id  #taking the value from the module above
  vpc_id-for-EC2 = module.vpc-module.my-main-vpc-output.id  # taken  the value from the module above #so the servers in the vpc can be associated weith the secuerity group
}


