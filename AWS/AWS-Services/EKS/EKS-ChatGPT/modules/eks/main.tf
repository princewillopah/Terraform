# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "20.8.4"

#   cluster_name    = var.cluster_name
#   cluster_version = "1.29"

#   vpc_id     = var.vpc_id
#   subnet_ids = var.private_subnets

#   cluster_endpoint_private_access = true
#   cluster_endpoint_public_access  = false

#   enable_irsa = true

#   cluster_addons = {
#     coredns = { most_recent = true }
#     kube-proxy = { most_recent = true }
#     vpc-cni = {
#       most_recent = true
#       configuration_values = jsonencode({
#         env = {
#           ENABLE_PREFIX_DELEGATION = "true"
#         }
#       })
#     }
#   }

#   tags = var.tags
# }
