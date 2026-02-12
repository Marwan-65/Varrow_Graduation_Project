output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "intra_subnet_ids" {
  value = module.vpc.intra_subnets
}

output "regional_nat_gateway_id" {
  value = aws_nat_gateway.regional.id
}
