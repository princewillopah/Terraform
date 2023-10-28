# -------------------------------------------------------------------------------
# Basic IAM USER
# -------------------------------------------------------------------------------

# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "5.19.0"
#     }
#   }
# }

# provider "aws" {
#   # Configuration options
#   region = "eu-north-1"
# }

# resource "aws_iam_user" "princewill-user3" {
#   name = "basic-user"  # Set the name of the IAM user.
#   path = "/system/"   # Set the path for the IAM user.
#   # Define tags for the IAM user.
#   tags = {
#     tag-key = "User to create EC2"
#   }
# }

# -------------------------------------------------------------------------------
# IAM USER with policy  -- mewthd 1
# -------------------------------------------------------------------------------
# # Set up the AWS provider and region
# provider "aws" {
#   region = "us-east-1" # Replace with your desired AWS region
# }
# # Define the IAM user resource block with the desired name and path
# resource "aws_iam_user" "princewill_user" {
#   name = "princewill-user" # Set the name of the IAM user
#   path = "/princewill/"    # Set the path for the IAM user
#   #   # Define tags for the IAM user.
#   tags = {
#     tag-key = "User to create EC2"
#   }
# }
# # Define the IAM policy resource block with the desired name and permissions.
# resource "aws_iam_policy" "princewill_policy" {
#   name        = "princewill-policy" # Set the name of the IAM policy
#   description = "An princewill IAM policy"
  
#   # Define the permissions for the policy
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action   = ["s3:GetObject", "s3:ListBucket"],
#         Effect   = "Allow",
#         Resource = "*",
#       },
#       {
#         Action   = "ec2:Describe*",
#         Effect   = "Allow",
#         Resource = "*",
#       },
#     ],
#   })
# }
# # Define the IAM policy attachment resource block to attach the policy to the user
# resource "aws_iam_policy_attachment" "princewill_user_policy" {
#   name       = "princewill-user-policy-attachment" # Set the name for the policy attachment
#   policy_arn = aws_iam_policy.princewill_policy.arn  # Reference the ARN of the policy
#   users      = [aws_iam_user.princewill_user.name]   # Reference the IAM user by name
# }


# -------------------------------------------------------------------------------
# IAM USER with policy  --mewthod 2
# -------------------------------------------------------------------------------
# # Set up the AWS provider and region
# provider "aws" {
#   region = "eu-north-1" # Replace with your desired AWS region
# }
# # Define the IAM user resource block with the desired name and path
# resource "aws_iam_user" "princewill_user" {
#   name = "princewill-user" # Set the name of the IAM user
#   path = "/princewill/"    # Set the path for the IAM user
#   #   # Define tags for the IAM user.
#   tags = {
#     tag-key = "User to create EC2"
#   }
# }
# # Define the IAM policy resource block with the desired name and permissions.
# resource "aws_iam_policy" "princewill_policy" {
#   name        = "princewill-policy" # Set the name of the IAM policy
#   description = "An princewill IAM policy"
  
#   # Define the permissions for the policy
#   policy = file("my-policy-file.json")
# }
# # Define the IAM User policy attachment resource block to attach the policy to the user
# resource "aws_iam_user_policy_attachment" "princewill_user_policy" {
#   policy_arn = aws_iam_policy.princewill_policy.arn  # Reference the ARN of the policy
#   user      = aws_iam_user.princewill_user.name   # Reference the IAM user by name
# }
