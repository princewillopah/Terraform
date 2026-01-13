# Providers (Multi-Region Required)
# For CloudFront and ACM, us-east-1 is required i.e ⚠️ ACM for CloudFront MUST be in us-east-1

provider "aws" {
  # region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
