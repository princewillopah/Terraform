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
module "instance_profile" { ## VPC 1 (Requester VPC)
  source           = "./modules/roles"

}
module "ConsumerVPC" { ## VPC 1 (Requester VPC)
  source           = "./modules/Consumer-VPC"
  key_name         = var.key_name
  ssm_instance_profile  = module.instance_profile.SSMInstanceProfile

}
module "ProviderVPC" {## VPC 2 (Accepter VPC)
  source           = "./modules/Provider-VPC"
  key_name         = var.key_name
  ssm_instance_profile  = module.instance_profile.SSMInstanceProfile
}


# module "vpc1_to_vpc2_peering_connection" {
#   source               = "./modules/terraform-vpc-peering"
#   vpc_1_id              = module.vpc1.vpc1_id
#   vpc_2_id              = module.vpc2.vpc2_id

#   vpc1_private_rt       = module.vpc1.vpc1_private_rt
#   vpc2_cidr_block       = module.vpc2.vpc2_cidr

#   vpc2_private_rt       = module.vpc2.vpc2_private_rt
#   vpc1_cidr_block       = module.vpc1.vpc1_cidr
# }