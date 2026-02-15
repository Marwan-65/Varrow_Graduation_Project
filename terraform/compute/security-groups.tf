############################################
# Security Groups for EKS and Jump Server
############################################

# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name        = "${var.environment}-${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = local.vpc_id

  tags = {
    Name        = "${var.environment}-${var.cluster_name}-cluster-sg"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Allow inbound API traffic from nodes to cluster
resource "aws_security_group_rule" "eks_cluster_inbound" {
  description              = "Allow API access from nodes"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

# ✅ NEW: Allow inbound API traffic from Jump Server to cluster
resource "aws_security_group_rule" "eks_cluster_inbound_from_jump" {
  description              = "Allow API access from Jump Server"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.jump_server.id
}

# Allow outbound from cluster to nodes
resource "aws_security_group_rule" "eks_cluster_outbound" {
  description              = "Allow outbound to nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

# EKS Nodes Security Group
resource "aws_security_group" "eks_nodes" {
  name        = "${var.environment}-${var.cluster_name}-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = local.vpc_id

  tags = {
    Name        = "${var.environment}-${var.cluster_name}-nodes-sg"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Node-to-Node communication
resource "aws_security_group_rule" "eks_nodes_internal" {
  description              = "Allow node-to-node communication"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

# Allow nodes to receive API traffic from cluster
resource "aws_security_group_rule" "eks_nodes_from_cluster" {
  description              = "Allow inbound from cluster"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
}

# Allow nodes to receive web traffic from ALB
resource "aws_security_group_rule" "eks_nodes_from_alb" {
  description              = "Allow inbound from ALB"
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.alb.id
}

# Node outbound rules
resource "aws_security_group_rule" "eks_nodes_outbound" {
  description       = "Allow outbound internet access"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes.id
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.environment}-${var.cluster_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = local.vpc_id

  tags = {
    Name        = "${var.environment}-${var.cluster_name}-alb-sg"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Allow HTTP from internet to ALB
resource "aws_security_group_rule" "alb_http_inbound" {
  description       = "Allow HTTP from internet"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

# ALB outbound to nodes
resource "aws_security_group_rule" "alb_outbound_to_nodes" {
  description              = "Allow outbound to nodes"
  type                     = "egress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

# Jump Server Security Group
resource "aws_security_group" "jump_server" {
  name        = "${var.environment}-${var.cluster_name}-jump-sg"
  description = "Security group for Jump Server"
  vpc_id      = local.vpc_id

  tags = {
    Name        = "${var.environment}-${var.cluster_name}-jump-sg"
    Environment = var.environment
    Terraform   = "true"
  }
}

# No inbound rules - SSM access only
# SSM Agent requires outbound HTTPS to AWS endpoints

resource "aws_security_group_rule" "jump_server_outbound" {
  description       = "Allow outbound HTTPS for SSM"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jump_server.id
}

# Also allow outbound to EKS API
resource "aws_security_group_rule" "jump_server_outbound_eks" {
  description              = "Allow outbound to EKS API"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.jump_server.id
  source_security_group_id = aws_security_group.eks_cluster.id
}

# Allow outbound to nodes for kubectl exec/logs etc
resource "aws_security_group_rule" "jump_server_outbound_nodes" {
  description              = "Allow outbound to nodes for kubectl"
  type                     = "egress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.jump_server.id
  source_security_group_id = aws_security_group.eks_nodes.id
}
