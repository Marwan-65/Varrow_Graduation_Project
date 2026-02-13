############################################
# ECR Repository for Nginx images
############################################

resource "aws_ecr_repository" "nginx" {
  name = var.ecr_repository_name

  # MUTABLE
  image_tag_mutability = "MUTABLE"

  # Automatically scan images for security vulnerabilities
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
    Name        = "${var.environment}-${var.ecr_repository_name}"
  }
}

# Automatically clean up old images
resource "aws_ecr_lifecycle_policy" "nginx" {
  repository = aws_ecr_repository.nginx.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}
