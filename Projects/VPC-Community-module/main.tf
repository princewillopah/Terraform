# VPC Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "example_security_group" {
  name_prefix = "example-security-group"
  description = "Example security group"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "example_instance" {
  ami           = "ami-0989fb15ce71ba39e"  # Replace with your AMI ID
  instance_type = "t3.micro"
  subnet_id     = module.vpc.public_subnets[0]  # Choose a subnet

  key_name      = "my-ssh-key"  # Replace with your SSH key name
 vpc_security_group_ids = [aws_security_group.example_security_group.id]
  tags = {
    Name = "example-instance"
  }

#   # Remote Exec Provisioner for NGINX
#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt-get update",
#       "sudo apt-get install -y nginx",
#     ]
#   }
user_data = file("docker-container.sh") #handles instalation of docker on ec2 instance and running nginx on it

}

# SSH Key Pair
resource "aws_key_pair" "example_keypair" {
  key_name   = "my-ssh-key"  # Replace with your desired key name
  public_key = file("~/.ssh/my_ssh_key_for_my_main_linux_ec2.pub")  # Replace with the path to your public key file
}
