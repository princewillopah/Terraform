# #------------------------------------------------------
# # aws_iam_role_policy_attachment — what the EC2 can do
# #------------------------------------------------------
# # Attach policies (SSM, CloudWatch logs) as needed
# # Attaches AmazonSSMManagedInstanceCore policy to the EC2 role.
# # This allows:
# #   AWS Systems Manager (SSM)
# #   Session Manager (SSH-less access)
# #   Inventory & patching
# # This is why you can log in without port 22

# resource "aws_iam_role_policy_attachment" "ssm_attach" {
#   count      = var.attach_ssm ? 1 : 0
#   role       = aws_iam_role.ec2_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }
# resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
#   count      = var.attach_cloudwatch ? 1 : 0
#   role       = aws_iam_role.ec2_role.name
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
# }

# #----------------------------------------------
# # aws_iam_role — who the EC2 is allowed to be
# #----------------------------------------------
# # This defines an IAM role
# # The role itself does nothing yet
# # It’s like creating an ID card but not granting permissions

# resource "aws_iam_role" "ec2_role" {
#   name               = "${var.name}-ec2-role"
#   assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
# }


# #----------------------------------------------------------
# # data "aws_iam_policy_document" — who can assume the role
# #----------------------------------------------------------
# # This says: “EC2 instances are allowed to use this role”
# # Without this, EC2 cannot attach the role
# # This is mandatory for every EC2 role
# data "aws_iam_policy_document" "ec2_assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }


# #--------------------------------------------------------------
# # aws_iam_instance_profile — bridge between EC2 and IAM role
# #--------------------------------------------------------------
# # This creates an instance profile that can be attached to EC2 instances
# # EC2 cannot attach IAM roles directly
# # It attaches an instance profile
# # Instance profile = wrapper around the role
# # 👉 This is what you reference in aws_instance


# resource "aws_iam_instance_profile" "ec2_profile" {
#   name = "${var.name}-instance-profile"
#   role = aws_iam_role.ec2_role.name
# }

