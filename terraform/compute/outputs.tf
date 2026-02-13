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
