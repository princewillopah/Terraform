terraform {
  backend "s3" {
    bucket         = "prod-terraform-state"
    key            = "eks/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
