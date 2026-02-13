############################################
# IAM Roles and Instance Profiles
############################################

############################################
# EKS Cluster Role
############################################
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.environment}-${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

############################################
# EKS Node Role
############################################
resource "aws_iam_role" "eks_node_role" {
  name = "${var.environment}-${var.cluster_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_worker_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_ecr_readonly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Node Instance Profile (required for managed node groups / EC2 nodes)
resource "aws_iam_instance_profile" "eks_node_instance_profile" {
  name = "${var.environment}-${var.cluster_name}-eks-node-instance-profile"
  role = aws_iam_role.eks_node_role.name
}

############################################
# Jump Server Role (SSM-only)
############################################
resource "aws_iam_role" "jump_server_role" {
  name = "${var.environment}-${var.cluster_name}-jump-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# SSM permissions (required for Session Manager access)
resource "aws_iam_role_policy_attachment" "jump_ssm_policy" {
  role       = aws_iam_role.jump_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Allow Jump Server to describe EKS cluster (required for aws eks update-kubeconfig)
resource "aws_iam_role_policy" "jump_eks_describe" {
  name = "${var.environment}-${var.cluster_name}-jump-eks-describe"
  role = aws_iam_role.jump_server_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "*"
      }
    ]
  })
}

# Jump Server Instance Profile
resource "aws_iam_instance_profile" "jump_instance_profile" {
  name = "${var.environment}-${var.cluster_name}-jump-instance-profile"
  role = aws_iam_role.jump_server_role.name
}
