############################################
# Jump Server - Task 3.8
############################################

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "jump_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = local.private_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.jump_server.id]
  iam_instance_profile        = aws_iam_instance_profile.jump_instance_profile.name
  associate_public_ip_address = false

  tags = {
    Name        = "${var.environment}-${var.cluster_name}-jump-server"
    Environment = var.environment
    Terraform   = "true"
  }
}
