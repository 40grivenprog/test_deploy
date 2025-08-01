variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "domain_name" {
  description = "Domain name for Route53"
  type        = string
  default     = "example.com"  # Замените на ваш домен
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "test-deploy"
} 