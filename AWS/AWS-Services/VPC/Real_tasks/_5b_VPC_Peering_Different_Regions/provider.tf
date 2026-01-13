provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "usw2"
  region = "us-west-2"
}

provider "aws" {
  alias  = "euw1"
  region = "eu-west-1"
}
