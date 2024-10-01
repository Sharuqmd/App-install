# Kubernetes API Endpoint
output "eks_cluster_endpoint" {
  description = "The Kubernetes API server endpoint"
  value       = module.eks.cluster_endpoint
}

# Command to update kubeconfig for kubectl usage
output "kubectl_config_command" {
  description = "Command to configure kubectl for this EKS cluster"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${local.cluster_name}"
}

# EKS Cluster Name
output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_id
}

# VPC ID
output "vpc_id" {
  description = "The VPC ID where the EKS cluster is deployed"
  value       = var.vpc_id
}

# Subnets
output "subnets" {
  description = "The Subnet IDs used by the EKS cluster"
  value       = var.subnets
}
