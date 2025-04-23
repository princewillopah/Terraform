# The IAM instance profile attaches the IAM role to the EC2 instance, allowing it to assume the role and 
# gain the necessary permissions to interact with other AWS services


resource "aws_iam_instance_profile" "instance-profile" {
  name = "Jenkins-instance-profile"
  role = aws_iam_role.iam-role.name
}