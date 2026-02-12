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
