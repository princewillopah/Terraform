# use data source to get all avalablility zones in region
data "aws_availability_zones" "my-available_zones" {}


module "my-eks-vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "my-vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.my-available_zones.names
  private_subnets =  var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs
  intra_subnets = var.intra_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true


  tags = {
    Terraform = "true"
    Environment = "dev"
  }

  public_subnet_tags = {"kubernetes.io/role/elb" = 1}
  private_subnet_tags = {"kubernetes.io/role/internal-elb" = 1}
}
