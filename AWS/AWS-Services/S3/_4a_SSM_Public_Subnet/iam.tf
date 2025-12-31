# -------------------------------------------------------------------------------
# This resource only creates the role and its trust policy, specifically intended to be assumed by EC2 instances.
# -------------------------------------------------------------------------------
resource "aws_iam_role" "ec2_role" {# Creates an IAM role named ec2-role - # Allows EC2 instances to assume it
  name = "ec2-ssm-and-s3-role"

  assume_role_policy = jsonencode({  # Defines the Trust Policy (assume_role_policy)
    Version = "2012-10-17"  # It uses AWS's IAM policy language version 2012-10-17
    Statement = [{ # It contains a single Statement that:
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}


# ---------------------------------------------
# Attash the SSM policy to the role above
# ---------------------------------------------
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ---------------------------------------------
# Custom S3 Policy (Least Privilege)
# ---------------------------------------------
resource "aws_iam_role_policy" "s3_access" {   
  name = "ec2-s3-bucket-access"
  role = aws_iam_role.ec2_role.id  ## this is attched to the role 

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",        # Optional: only if you need delete
          "s3:ListBucket"
          # "s3:PutObjectAcl",   # Optional: if you set ACLs
          # "s3:RestoreObject"   # Optional: if using Glacier
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",          # Bucket ARN (for ListBucket)
          "arn:aws:s3:::${var.s3_bucket_name}/*"         # Objects inside
        ]
      }
    ]
  })
}

# ---------------------------------------------
# Creat a profile for the ec2 instance
# ---------------------------------------------





resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ec2_role.name
}
