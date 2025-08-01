terraform {
  required_version = ">= 1.0"
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

# Минимальная VPC (только публичные подсети для экономии)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.0"

  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = []

  enable_nat_gateway = false
  single_nat_gateway = false
  
  map_public_ip_on_launch = true

  tags = {
    Project = var.project_name
  }
}

# Минимальный EKS кластер
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = "${var.project_name}-cluster"
  cluster_version = "1.28"
  subnet_ids      = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id

  # Отключаем шифрование для экономии
  create_kms_key = false
  cluster_encryption_config = {}

  # Включаем публичный доступ к API
  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      max_size     = 2
      min_size     = 1

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Project = var.project_name
  }
} 