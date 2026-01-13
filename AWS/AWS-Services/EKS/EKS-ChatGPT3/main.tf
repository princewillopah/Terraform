############################
# Terraform & Provider Lock
############################
terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

############################
# Variables
############################
variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "fresh-eks-cluster"
}

variable "cluster_version" {
  default = "1.30"
}

variable "node_instance_type" {
  default = "t3.medium"
}

variable "desired_capacity" {
  default = 2
}

variable "max_size" {
  default = 4
}

variable "min_size" {
  default = 1
}

############################
# Data
############################
data "aws_availability_zones" "available" {}

############################
# Providers
############################
provider "aws" {
  region = var.region
}

############################
# VPC
############################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = ["10.0.101.0/24","10.0.102.0/24","10.0.103.0/24"]
  private_subnets = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]

  enable_nat_gateway   = true
  one_nat_gateway_per_az = true

  enable_dns_support   = true
  enable_dns_hostnames = true

#  associate_public_ip_address = false

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

############################
# KMS Key for Secrets Encryption
############################
resource "aws_kms_key" "eks" {
  description             = "EKS Secrets Encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags = { Name = "${var.cluster_name}-kms-key" }
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${var.cluster_name}-eks-secrets"
  target_key_id = aws_kms_key.eks.key_id
}

############################
# EKS Cluster
############################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets   # Public subnets for endpoint

  enable_irsa = true

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false   # Start with public only

  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }

  cluster_enabled_log_types = ["api","audit","authenticator","controllerManager","scheduler"]

  eks_managed_node_groups = {
    workers = {
      desired_capacity = var.desired_capacity
      min_size         = var.min_size
      max_size         = var.max_size

      instance_types = [var.node_instance_type]
      capacity_type  = "ON_DEMAND"

      labels = { role = "worker" }

      tags = {
        "k8s.io/cluster-autoscaler/enabled" = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }
    }
  }

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}

############################
# Kubernetes/Helm Providers (for later use)
############################
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
    }
  }
}
############################
# outputs
############################
output "kubeconfig_command" {
  description = "Command to update kubeconfig"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}
