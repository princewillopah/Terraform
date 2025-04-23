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
  source            = "./modules/public_subnet"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  key_name = var.key_name
  # public_subnet_cidr = var.public_subnet_cidr
  # public_ami = var.public_ami
}

module "private_subnet" {
  source               = "./modules/private_subnet"
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  key_name             = var.key_name
  # private_subnet_cidr  = var.private_subnet_cidr
  # private_ami          =  var.private_ami
}