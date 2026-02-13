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

variable "eks_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.31"
}

variable "vpc_cni_version" {
  description = "Version of VPC CNI add-on"
  type        = string
  default     = "v1.18.3-eksbuild.3"
}

variable "coredns_version" {
  description = "Version of CoreDNS add-on"
  type        = string
  default     = "v1.11.1-eksbuild.9"
}

variable "kube_proxy_version" {
  description = "Version of kube-proxy add-on"
  type        = string
  default     = "v1.31.1-eksbuild.2"
}

variable "ebs_csi_version" {
  description = "Version of EBS CSI driver add-on"
  type        = string
  default     = "v1.35.0-eksbuild.1"
}
