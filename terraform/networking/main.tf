############################################
# Networking - main.tf
# VPC + Subnets via module
# Regional NAT Gateway (AWS new feature) via native resources
############################################

locals {
  environment  = var.environment
  cluster_name = "varrow-eks-cluster"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs
  intra_subnets   = var.intra_subnet_cidrs

  # IMPORTANT:
  # Disable module NAT (zonal) because we will create Regional NAT ourselves below.
  enable_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  # EKS subnet tags
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Environment = local.environment
    Terraform   = "true"

    # This tag lets EKS discover the subnets
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

############################################
# Regional NAT Gateway prerequisites:
# One EIP per AZ (Regional NAT uses AZ addresses)
############################################

resource "aws_eip" "regional_nat" {
  for_each = toset(var.azs)

  domain = "vpc"

  tags = {
    Environment = local.environment
    Terraform   = "true"
    Name        = "${local.environment}-regional-nat-${each.key}"
  }
}

############################################
# Regional NAT Gateway (NO subnet_id!)
############################################

resource "aws_nat_gateway" "regional" {
  availability_mode = "regional"
  connectivity_type = "public"

  # REQUIRED for regional NAT:
  vpc_id = module.vpc.vpc_id

  # Attach AZ addresses (EIPs) for each AZ
  dynamic "availability_zone_address" {
    for_each = toset(var.azs)
    content {
      availability_zone = availability_zone_address.value
      allocation_ids    = [aws_eip.regional_nat[availability_zone_address.value].id]
    }
  }

  tags = {
    Environment = local.environment
    Terraform   = "true"
    Name        = "${local.environment}-regional-nat"

    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

############################################
# Route private route tables -> Regional NAT
############################################

resource "aws_route" "private_default_to_regional_nat" {
  for_each = toset(module.vpc.private_route_table_ids)

  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.regional.id
}