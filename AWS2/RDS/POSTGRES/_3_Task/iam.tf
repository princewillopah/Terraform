# ===========================
# IAM Role for SSM
# ===========================
# This file defines the IAM role for SSM, which allows us to connect to our EC2 instance using Session Manager instead of SSH.
# This is optional but recommended for better security (no open SSH ports) and convenience (no need to manage SSH keys).

resource "aws_iam_role" "ssm_role" {
  name = "${var.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ===========================
# Attach AWS Managed SSM Policy
# ===========================
# Attach the AmazonSSMManagedInstanceCore policy to the role, which gives it the necessary permissions to work with SSM.
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ===========================
# Create Instance Profile
# ===========================
# Create an instance profile for the IAM role, which allows EC2 instances to assume the role.
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "${var.project_name}-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}
