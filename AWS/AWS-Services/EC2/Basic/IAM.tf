# # -----------------------------
# # IAM Role, Policy, Profile for SSM
# # -----------------------------
# resource "aws_iam_role" "ssm_role" {
#   name = "EC2SSMRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#   })
# }

# # Attach SSM Managed Policy
# resource "aws_iam_role_policy_attachment" "ssm_attach" {
#   role       = aws_iam_role.ssm_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# # IAM Instance Profile
# resource "aws_iam_instance_profile" "ssm_profile" {
#   name = "EC2SSMInstanceProfile"
#   role = aws_iam_role.ssm_role.name
# }
