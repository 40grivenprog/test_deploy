output "cluster_name" {
  value = module.eks.cluster_name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
  description = "EKS cluster endpoint"
}

output "vpc_id" {
  value = module.vpc.vpc_id
  description = "VPC ID"
} 