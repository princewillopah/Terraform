
module "vpc-module" {
  source = "./modules/VPC"
  environment = var.env_prefix
  azs = var.avail_zone
 
}


# module "EKS-module" {
#   source = "./modules/EKS"
#   EKS-VPC-ID = module.vpc-module.my-main-vpc-output.id
#   EKS-Subnet-IDs = concat(module.vpc-module.public_subnet_ids, module.vpc-module.private_subnet_ids)
#   EKS-SG =  module.vpc-module.output-node-group-sg.id
# }
module "EKS-module" {
  source = "./modules/EKS"
  EKS-VPC-ID      = module.vpc-module.vpc_id
  # EKS-Subnet-IDs  = concat(module.vpc-module.public_subnet_ids, module.vpc-module.private_subnet_ids)
  EKS-Subnet-IDs = concat(module.vpc-module.public_subnet_ids, module.vpc-module.private_subnet_ids)
  EKS-SG          = module.vpc-module.eks_worker_nodes_sg_id
}

# module "EC2-module" {
#   source = "./modules/EC2"
#   EC2_env_prefix = var.env_prefix
#   EC2_avail_zone = var.avail_zone
#   public_key_location = var.SSH_public_key_location
#   subnet-id-for-EC2 = module.vpc-module.my-main-subnet-output1.id  #taking the value from the module above
#   vpc_id-for-EC2 = module.vpc-module.my-main-vpc-output.id  # taken  the value from the module above #so the servers in the vpc can be associated weith the secuerity group
# }

# we need the output to be exported so the other modules that need it can use it 
