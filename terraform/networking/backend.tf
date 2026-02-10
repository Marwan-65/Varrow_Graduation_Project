terraform {
  backend "s3" {
    bucket = "varrow-academy-devops-networking-terraform-backend-us-east-1"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}
