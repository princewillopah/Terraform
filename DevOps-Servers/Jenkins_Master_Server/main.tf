resource "aws_iam_role" "jenkins_role" {
  name = "Jenkins-Master-Server"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

### giving the instance full admin policy
# resource "aws_iam_role_policy_attachment" "example_attachment" {
#   role       = aws_iam_role.example_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }

# Attach AmazonEC2ContainerRegistryFullAccess Policy for ECR access
resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# Attach AWS-managed policy for Secrets Manager (Read/Write)
resource "aws_iam_role_policy_attachment" "secrets_manager_policy_attachment" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_instance_profile" "Jenkins_profile" {
  name = "Jenkins-Master-Server"
  role = aws_iam_role.jenkins_role.name
}


resource "aws_security_group" "Jenkins-sg" {
  name        = "Jenkins-Security Group"
  description = "Open 22,443,80,8080,9000,8086,9090,5000"

  # Define a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22,25, 80, 443,465, 8080, 8081, 9000, 3000, 5000, 8086, 9090] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}--security-group"
  }
}

resource "aws_instance" "Jenkins-Master-Instance" {
  ami           = "ami-0014ce3e52359afbd" # for eu-north-1
  instance_type = "t3.large"
  key_name               = var.ssh-key
  vpc_security_group_ids = [aws_security_group.Jenkins-sg.id]
  associate_public_ip_address    = true # to make sure public ip is display
  iam_instance_profile   = aws_iam_instance_profile.Jenkins_profile.name
  user_data              = templatefile("./script.sh", {})

  root_block_device {
    volume_size = 40
    volume_type = "gp2"
  }
  tags = {
    Name = "${var.environment}"
  }
}

