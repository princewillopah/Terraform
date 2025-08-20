# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "prod/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"  # For state locking
#     encrypt        = true
#   }
# }