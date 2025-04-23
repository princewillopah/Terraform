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

module "my-s3" {
  source           = "./modules/s3"
  environment      = var.environment
  # vpc_cidr       = var.vpc_cidr
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
  s3_access_instance_profile_name = module.ec2-permissions-to-s3.s3_access_instance_profile_name
  # public_subnet_cidr = var.public_subnet_cidr
  # public_ami = var.public_ami
}

module "private_subnet" {
  source                          = "./modules/private_subnet"
  environment                     = var.environment
  vpc_id                          = module.vpc.vpc_id
  key_name                        = var.key_name
  s3_access_instance_profile_name = module.ec2-permissions-to-s3.s3_access_instance_profile_name
  # private_subnet_cidr  = var.private_subnet_cidr
  # private_ami          =  var.private_ami
}

module "ec2-permissions-to-s3" {
  source           = "./modules/permissions"
  bucket_prefix    = module.my-s3.common_name_of_s3_buckets_created 
  bucket_count     = module.my-s3.number_of_s3_buckets_created

  # environment      = var.environment
  # vpc_cidr       = var.vpc_cidr
}