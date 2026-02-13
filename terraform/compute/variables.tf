variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
  default     = "varrow-eks-cluster"
}
variable "ecr_repository_name" {
  description = "Name of the ECR repository for Nginx images"
  type        = string
  default     = "varrow-nginx"
}
