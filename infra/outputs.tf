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

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "go_app_url" {
  description = "Go App URL"
  value       = "https://app.${var.domain_name}"
}

output "argocd_url" {
  description = "ArgoCD URL"
  value       = "https://argocd.${var.domain_name}"
}

output "route53_nameservers" {
  description = "Route53 nameservers"
  value       = aws_route53_zone.main.name_servers
} 