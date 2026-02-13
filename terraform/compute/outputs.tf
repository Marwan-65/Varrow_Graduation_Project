output "networking_vpc_id" {
  value = local.vpc_id
}

output "networking_private_subnet_ids" {
  value = local.private_subnet_ids
}
output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

output "jump_server_role_arn" {
  value = aws_iam_role.jump_server_role.arn
}

output "eks_node_instance_profile_name" {
  value = aws_iam_instance_profile.eks_node_instance_profile.name
}

output "jump_instance_profile_name" {
  value = aws_iam_instance_profile.jump_instance_profile.name
}

# Security Group outputs
output "eks_cluster_security_group_id" {
  description = "ID of the EKS cluster security group"
  value       = aws_security_group.eks_cluster.id
}

output "eks_nodes_security_group_id" {
  description = "ID of the EKS worker nodes security group"
  value       = aws_security_group.eks_nodes.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "jump_server_security_group_id" {
  description = "ID of the jump server security group"
  value       = aws_security_group.jump_server.id
}

# ECR outputs - so you can see the repository URL
output "ecr_repository_url" {
  description = "URL of the ECR repository for Nginx"
  value       = aws_ecr_repository.nginx.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.nginx.arn
}

# EKS Cluster outputs
output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_certificate_authority" {
  description = "Certificate authority data for EKS cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = aws_eks_cluster.main.version
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "eks_cluster_status" {
  description = "Status of the EKS cluster"
  value       = aws_eks_cluster.main.status
}
