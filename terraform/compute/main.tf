data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "varrow-academy-devops-networking-terraform-backend-us-east-1"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
}
