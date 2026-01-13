output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "kubeconfig_command" {
  description = "Command to update kubeconfig"
  value       = "aws eks update-kubeconfig --name prod-eks-cluster --region us-west-2"
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "platform_version" {
  value = module.eks.cluster_platform_version
}