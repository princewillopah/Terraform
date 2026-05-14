###############################################################################
# TERRAFORM - AWS RDS PostgreSQL (Staging/Dev)
# Access: EC2 app in same VPC + Local machine via Bastion Host
# Level: Beginner-friendly with comments explaining every decision
###############################################################################

terraform {
  required_version = ">= 1.5.0"    # Requires Terraform v1.5+

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

###############################################################################
# DATA SOURCES
###############################################################################

# Fetch all availability zones in the selected region, dynamically
# To be used later for subnet distribution and RDS Multi-AZ deployment options.
data "aws_availability_zones" "available" {
  state = "available"
}

# Get your current public IP so only YOU can SSH into the Bastion
# (This is optional — you can hardcode your IP in variables.tf instead)
data "http" "my_public_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  # Trim newline from IP response in this format "<your_ip>/32" and store in a local variable(local.my_ip) for reuse in security group rules.
  my_ip = "${chomp(data.http.my_public_ip.response_body)}/32"
}


