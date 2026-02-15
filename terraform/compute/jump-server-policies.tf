############################################
# Jump Server IAM Policies - COMPLETE FIX
# All permissions for the Jump Server in one place
############################################

# Custom policy for Jump Server (includes SSM + ECR + EKS)
resource "aws_iam_policy" "jump_server_custom" {
  name        = "${var.environment}-${var.cluster_name}-jump-server-custom-policy"
  description = "All permissions for Jump Server (SSM, ECR, EKS)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # SSM Permissions (replaces the managed policy)
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeAssociation",
          "ssm:GetDeployablePatchSnapshotForInstance",
          "ssm:GetDocument",
          "ssm:DescribeDocument",
          "ssm:GetManifest",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:ListAssociations",
          "ssm:ListInstanceAssociations",
          "ssm:PutInventory",
          "ssm:PutComplianceItems",
          "ssm:PutConfigurePackageResult",
          "ssm:UpdateAssociationStatus",
          "ssm:UpdateInstanceAssociationStatus",
          "ssm:UpdateInstanceInformation"
        ]
        Resource = "*"
      },
      # ECR Permissions (for pushing/pulling images)
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },
      # EKS Permissions (for kubectl)
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# Attach the custom policy to Jump Server role
resource "aws_iam_role_policy_attachment" "jump_server_custom" {
  role       = aws_iam_role.jump_server_role.name
  policy_arn = aws_iam_policy.jump_server_custom.arn
}

# NO duplicate data source - using existing one
# NO duplicate SSM attachment - this file handles ALL permissions
# NO duplicate output - removing it
