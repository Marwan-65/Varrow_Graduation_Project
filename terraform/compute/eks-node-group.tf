############################################
# EKS Managed Node Group
############################################

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "varrow-eks-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = local.private_subnet_ids

  # Acceptance criteria: Instance type = t3.small
  instance_types = ["t3.small"]

  # Acceptance criteria: AMI = Amazon Linux 2023 EKS
  ami_type = "AL2023_x86_64_STANDARD"

  # Acceptance criteria: Disk size = 20 GB
  disk_size = 20

  # Acceptance criteria: Min 1 / Desired 1 / Max 2
  scaling_config {
    min_size     = 1
    desired_size = 1
    max_size     = 2
  }

  # Optional but recommended: clean upgrade behavior
  update_config {
    max_unavailable = 1
  }

  tags = {
    Name        = "varrow-eks-nodes"
    Environment = var.environment
    Terraform   = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_worker_policy,
    aws_iam_role_policy_attachment.eks_node_cni_policy,
    aws_iam_role_policy_attachment.eks_node_ecr_readonly
  ]
}
