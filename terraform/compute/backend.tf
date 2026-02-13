terraform {
  backend "s3" {
    bucket = "varrow-academy-devops-compute-terraform-backend-us-east-1"
    key    = "compute/terraform.tfstate"
    region = "us-east-1"
  }
}
