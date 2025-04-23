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
module "vpcA" { ## VPC-A
  source           = "./modules/VPC-A"
  environment      = var.environment
  key_name         = var.key_name

}

module "vpcB" { ## VPC-B
  source           = "./modules/VPC-B"
  environment      = var.environment
  key_name         = var.key_name

}
module "vpcC" {## VPC-C
  source           = "./modules/VPC-C"
  environment      = var.environment
  key_name         = var.key_name
}


module "vpc1_to_vpc2_peering_connectiontransit_gateway_for_vpca_vpcb_vpcc" {
  source               = "./modules/terraform-vpc-transit-gateway"
  vpc_a_id              = module.vpcA.vpc_A_id
  vpc_b_id              = module.vpcB.vpc_B_id
  vpc_c_id              = module.vpcC.vpc_C_id

  vpc_A_subnet_ids = module.vpcA.vpc_A_subnets_ids
  vpc_B_subnet_ids = [module.vpcB.vpc_B_subnet_id]# wrap in a list
  vpc_C_subnet_ids = [module.vpcC.vpc_C_subnet_id]# wrap in a list


  # Route table IDs and CIDR blocks
  vpc_A_private_rt      = module.vpcA.vpcA_private_rt
  vpc_B_private_rt      = module.vpcB.vpc_B_private_rt
  vpc_C_private_rt      = module.vpcC.vpc_C_private_rt

  vpc_A_cidr_block      = module.vpcA.vpcA_cidr
  vpc_B_cidr_block      = module.vpcB.vpc_B_cidr
  vpc_C_cidr_block      = module.vpcC.vpc_C_cidr

}

