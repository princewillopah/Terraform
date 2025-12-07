
data "aws_availability_zones" "azs" {}

module "vpc" {
  source = "./terraform-aws-3-tier-vpc-module"

  name               = "prod-network"
  cidr               = "10.10.0.0/16"
  azs                = data.aws_availability_zones.azs.names
  create_nat_per_az  = true

  tags = {
    Environment = "prod"
    Owner       = "Princewill"
  }
}
## ---------------------------------------------------------------------------
## To use the moduke, run the following commands:
## ---------------------------------------------------------------------------
## terraform init
## terraform plan -var='azs=["us-east-1a","us-east-1b","us-east-1c"]' -var='create_nat_per_az=true'
## terraform apply -var='azs=["us-east-1a","us-east-1b","us-east-1c"]' -auto-approve
