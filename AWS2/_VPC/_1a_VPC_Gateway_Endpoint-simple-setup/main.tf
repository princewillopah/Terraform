provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.61.0"
    }
  }
}



module "vpc" {
  source           = "./modules/vpc"
  environment      = var.environment
  # vpc_cidr       = var.vpc_cidr
}

module "public_subnet" {
  source                          = "./modules/public_subnet"
  environment                     = var.environment
  vpc_id                          = module.vpc.vpc_id
  key_name                        = var.key_name

}

module "private_subnet" {
  source                          = "./modules/private_subnet"
  environment                     = var.environment
  vpc_id                          = module.vpc.vpc_id
  key_name                        = var.key_name

}

module "my-vpc-endpoint" {
  source                          = "./modules/vpc-endpoint"
  aws_region                      = var.aws_region
  vpc_id                          = module.vpc.vpc_id
  environment                     = var.environment
  route_table_ids                 = module.private_subnet.my-private-route-table-id
#   key_name                        = var.key_name

}

module "my-s3" {
  source             = "./modules/s3"
  environment        = var.environment
  aws_region         = var.aws_region
  my-s3_vpc_endpoint = module.my-vpc-endpoint.s3-vpc-endpoint_id
  # vpc_cidr       = var.vpc_cidr
}