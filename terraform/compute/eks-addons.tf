
############################################
# EKS Add-ons - Task 3.6
############################################

# Get current AWS account ID for IAM roles (for future use)
data "aws_caller_identity" "current" {}

# 1. VPC CNI - Gives pods IP addresses from the VPC
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"
  addon_version = var.vpc_cni_version

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# 2. CoreDNS - DNS service discovery (commented for now - needs nodes)
# resource "aws_eks_addon" "coredns" {
#   cluster_name = aws_eks_cluster.main.name
#   addon_name   = "coredns"
#   addon_version = var.coredns_version
#   
#   depends_on = [
#     aws_eks_node_group.main
#   ]
#   
#   tags = {
#     Environment = var.environment
#     Terraform   = "true"
#   }
# }

# 3. kube-proxy - Network rules on each node
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"
  addon_version = var.kube_proxy_version

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# 4. EBS CSI Driver - Persistent storage (commented for now)
# resource "aws_eks_addon" "ebs_csi" {
#   cluster_name = aws_eks_cluster.main.name
#   addon_name   = "aws-ebs-csi-driver"
#   addon_version = var.ebs_csi_version
#   
#   tags = {
#     Environment = var.environment
#     Terraform   = "true"
#   }
# }

