module "vpc-module" {
 source = "../../modules/VPC-2"
 project_name = var.project_name
 vpc_cidr = var.vpc_cidr 
 public_subnet_cidrs = var.public_subnet_cidrs
#  public_subnet_az2_cidr = var.public_subnet_az2_cidr
}