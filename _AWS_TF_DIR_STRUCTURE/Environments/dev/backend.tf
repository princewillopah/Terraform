terraform {
  backend "s3" {
    bucket         = "princewill-terraform-state"  # Replace with your bucket name
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "princewill-terraform-lock-dynamoDB"  # For state locking
    encrypt        = true
  }
}