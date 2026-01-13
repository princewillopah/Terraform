

############################
# lock provider versions
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
# data and providers
############################

data "aws_availability_zones" "available" {}



provider "aws" {
  region = var.region
}

# --- Providers for Kubernetes/Helm ---
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}




############################
# variables
############################


variable "region" {
  default = "us-east-1"
}
variable "cluster_name" {
  default = "Apple-eks-cluster"
}
variable "cluster_version" {
  default = "1.30"
}

############################
# VPC
############################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name ="${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3) ##["us-west-2a", "us-west-2b", "us-west-2c"] # ← CHANGE IF NEEDED
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  one_nat_gateway_per_az = true

  enable_dns_support   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"            = "1"
  }
}

##################################
# KMS Key for Secrets Encryption
##################################

resource "aws_kms_key" "eks" {
  description             = "EKS Secrets Encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags = {
    Name = "${var.cluster_name}-kms-key"
  }
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${var.cluster_name}-eks-secrets"
  target_key_id = aws_kms_key.eks.key_id
}
############################
# EKS
############################


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    =  var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

    enable_irsa = true

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  ###-------------------------------------------
  # REQUIRED: EKS Access (cluster admin)
##----------------------------------------------
  #  access_entries = {
  #   admin = {
  #     principal_arn = "arn:aws:iam::016696895968:user/my-aws-user"
  #     policy_associations = {
  #       admin = {
  #         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  #         access_scope = { type = "cluster" }
  #       }
  #     }
  #   }
  # }


    cluster_encryption_config = {
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  eks_managed_node_groups = {
    workers = {
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      labels = { role = "workers" }

      tags = {
        "k8s.io/cluster-autoscaler/enabled" = "true"
        "k8s.io/cluster-autoscaler/prod-eks-cluster" = "owned"
      }
    }
  }

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}
############################
# IRSA FOR ALB CONTROLLER
############################

module "alb_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:aws-load-balancer-controller"
      ]
    }
  }
}

###############################
# Kubernetes & Helm Providers
###############################
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
  }

  # Optional: force refresh to avoid stale tokens
  # load_config_file       = false
}
# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }
# }

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}





######################################################
# Essential Add-ons - AWS Load Balancer Controller 
######################################################
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.alb_irsa.iam_role_arn
  }

  depends_on = [module.eks]
}



######################################################
# Essential Add-ons -  Metrics Server
######################################################
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  set_list {
    name  = "args"
    value = [
      "--kubelet-insecure-tls",
      "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname"
    ]
  }

  depends_on = [module.eks]
}
