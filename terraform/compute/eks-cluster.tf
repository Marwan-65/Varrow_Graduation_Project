
############################################
# EKS Cluster (Control Plane)
############################################

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids              = local.private_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
    security_group_ids      = [aws_security_group.eks_cluster.id]
    public_access_cidrs     = ["0.0.0.0/0"] # Open Access - FOR DEVELOPMENT ONLY
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
    Terraform   = "true"
  }
}

# Store kubeconfig data in SSM Parameter Store
resource "aws_ssm_parameter" "kubeconfig" {
  name  = "/eks/${var.cluster_name}/kubeconfig"
  type  = "String"
  value = <<-EOT
    apiVersion: v1
    clusters:
    - cluster:
        server: ${aws_eks_cluster.main.endpoint}
        certificate-authority-data: ${aws_eks_cluster.main.certificate_authority[0].data}
      name: ${var.cluster_name}
    contexts:
    - context:
        cluster: ${var.cluster_name}
        user: ${var.cluster_name}
      name: ${var.cluster_name}
    current-context: ${var.cluster_name}
    kind: Config
    preferences: {}
    users:
    - name: ${var.cluster_name}
      user:
        exec:
          apiVersion: client.authentication.k8s.io/v1beta1
          command: aws
          args:
          - eks
          - get-token
          - --cluster-name
          - ${var.cluster_name}
          - --region
          - us-east-1
  EOT

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_ssm_parameter" "cluster_endpoint" {
  name  = "/eks/${var.cluster_name}/endpoint"
  type  = "String"
  value = aws_eks_cluster.main.endpoint

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_ssm_parameter" "cluster_ca" {
  name  = "/eks/${var.cluster_name}/ca"
  type  = "String"
  value = aws_eks_cluster.main.certificate_authority[0].data

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
