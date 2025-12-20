output "vpc_id" {
  value       = module.vpc-module.vpc_id
  description = "VPC ID"
}

output "jump_server_connection_string" {
  value = "ssh -i ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ubuntu@${module.instance-module.public_ip}"
}

output "alb_dns_name" {
  value       = module.app_alb.alb_dns_name
  description = "Application Load Balancer DNS Name"
}

output "dns-nameservers" {
  value = module.dns_module.nameservers
  description = "DNS Nameservers to be used for domain delegation"
}

output "certificate_arn" {
  value = module.dns_module.certificate_arn
}

# output "public_subnets" {
#   value       = module.vpc.public_subnets
#   description = "VPC public subnets' IDs list"
# }
# output "private_subnets" {
#   value       = module.vpc.private_subnets
#   description = "VPC private subnets' IDs list"
# }
# output "cluster_id" {
#   value       = module.eks.cluster_name
#   description = "EKS Cluster Name ID"
# }