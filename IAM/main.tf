
# -------------------------------------------------------------------------------
# IAM USER with policy  --mewthod 2
# -------------------------------------------------------------------------------
# Set up the AWS provider and region
provider "aws" {
  region = "eu-north-1" # Replace with your desired AWS region
  profile = "default"
}
# Define the IAM user resource block with the desired name and path
resource "aws_iam_user" "princewill-opah-main-user" {
  name = "princewillopah" # Set the name of the IAM user
  path = "/"    # Set the path for the IAM user
  #   # Define tags for the IAM user.
  tags = {
    tag-key = "main IAM user"
  }
}
# Define the IAM policy resource block with the desired name and permissions.
resource "aws_iam_policy" "princewillopah_policy" {
  name        = "princewill-opah-policy" # Set the name of the IAM policy
  description = "An princewill IAM policy"
  
  # Define the permissions for the policy
  policy = file("policies/princewillopah-policy.json")
}
# Define the IAM User policy attachment resource block to attach the policy to the user
resource "aws_iam_user_policy_attachment" "princewillopah_user_policy" {
  policy_arn = aws_iam_policy.princewillopah_policy.arn  # Reference the ARN of the policy
  user      = aws_iam_user.princewill-opah-main-user.name   # Reference the IAM user by name
}
# Generate IAM user access keys
resource "aws_iam_access_key" "princewill_access_key" {
  user = aws_iam_user.princewill-opah-main-user.name # Reference the IAM user by name
  # pgp_key = "keybase:kelvingalabuzi"
}

# Define the IAM user login profile with the desired password
resource "aws_iam_user_login_profile" "princewillopah_user_login" {
  user = aws_iam_user.princewill-opah-main-user.name # Reference the IAM user by name
  password_reset_required = true # Set to true if password reset is required on first login

  # Define the password
  # pgp_key = "keybase:some_person_that_exists" # Replace with your PGP key

  # Alternatively, you can set a plain text password (not recommended for production use)
  # password = "YourPlainTextPassword"
}

# -------------outputs----------------------------------

output "Access_key_id" {
  value = aws_iam_access_key.princewill_access_key.id
}

output "Access_key_secret" {
  value = aws_iam_access_key.princewill_access_key.secret
  sensitive   = true   #To reduce the risk of accidentally exporting sensitive data that was intended to be only internal, Terraform requires that any root module output containing sensitive data be explicitly marked as sensitive, to confirm your intent.
  description = "The access key secret for the example user"
}

# Define an output to display the user's login profile details
output "user_login_profile" {
  value = aws_iam_user_login_profile.princewillopah_user_login
}