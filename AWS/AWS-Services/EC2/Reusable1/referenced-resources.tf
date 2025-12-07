data "aws_subnet" "private_app_1a" {
  id = "subnet-0ccf70adec7e3f621"
}

data "aws_subnet" "private_app_1b" {
  id = "subnet-0f7c254913eebf710"  # if it’s the same subnet
}
