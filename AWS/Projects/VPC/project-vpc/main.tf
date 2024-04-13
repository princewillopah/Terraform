module "vpc-module" {
 source = "../../modules/VPC"
 project_name = var.project_name
 vpc_cidr = var.vpc_cidr 
 public_subnet_az1_cidr = var.public_subnet_az1_cidr
 public_subnet_az2_cidr = var.public_subnet_az2_cidr


}