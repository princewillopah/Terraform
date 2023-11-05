# Define the provider for AWS
provider "aws" {
  region = "eu-north-1"  # Change this to your desired region
}

# Create an AWS key pair resource (replace "your-key-name" with your key pair name)
resource "aws_key_pair" "my_externally_created_ssh_key" {
  key_name   = "my-ssh-ky"
  public_key = file("~/.ssh/id_rsa.pub")  # Provide the path to your public key
}

# Create a security group to allow SSH access
resource "aws_security_group" "my_EC2_instance_sg" {
  name        = "example-security-group"
  description = "Example security group for SSH access"

 ingress {
    description      = "Open port 22 for cli access to the EC2 instance"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    # cidr_blocks      = [var.my-ip] only that stated ip will be able to access the ip
    cidr_blocks      = ["0.0.0.0/0"]  #for all ips to be able to access the ec2
  }
#rules to expose port 22 for aceessing ec2 instance ourside
  ingress {
    description      = "Open port 8080 for access of the nginx server in the ec2 instance from a browser "
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # expose to all ips sice is for all user
  }
#rules to expose port 22 for aceessing ec2 instance ourside
  ingress {
    description      = "Open port 8081 for access of the nexus server in the ec2 instance from a browser "
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # expose to all ips sice is for all user
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# the egress block handles rules for our resource within the vpc making requests or sending trafic outside the vpc to the internet. examples of such traffic is like when you want to install docker or other package in your EC2 instance, the binaries needs to be fectched or downloaded from the internet. another example, when we run an nginx image, the images has to be fetched from the dockerhub. these are requests made by the ec2 from your vpc to the internet  
  egress {
    description      = "rules to allow access of the resources inside the vpc to the internet"
    from_port        = 0 # not restricting the request to any port out there is to set the value to 0
    to_port          = 0 #same here
    protocol         = "-1"  # not to restricct the protocal to a particular ones, we set this to "any" by using -1
    cidr_blocks      = ["0.0.0.0/0"]  # any ip address out there
  }

  tags = {
    Name = "my--security-group"
  }
}

# Create EC2 instances
# resource "aws_instance" "my_EC2_instances_prod" {
#   count         = 2
#   ami           = "ami-0989fb15ce71ba39e" # for eu-north-1
#   instance_type = "t3.micro"

#   key_name      = aws_key_pair.my_externally_created_ssh_key.key_name
#   security_groups = [aws_security_group.my_EC2_instance_sg.name]

#   connection {
#     type        = "ssh"
#     user        = "ubuntu"  # For Amazon Linux 2
#     private_key = file("~/.ssh/id_rsa")  # Provide the path to your private key
#     host        = self.public_ip
#   }

#   tags = {
#     Name = "Prod_server-${count.index + 1}"
#   }
# }

# Create EC2 instances
resource "aws_instance" "my_EC2_instances_dev" {
  count         = 2
  ami           = "ami-0989fb15ce71ba39e" # for eu-north-1
  instance_type = "t3.micro"

  key_name      = aws_key_pair.my_externally_created_ssh_key.key_name
  security_groups = [aws_security_group.my_EC2_instance_sg.name]

  connection {
    type        = "ssh"
    user        = "ubuntu"  # For Amazon Linux 2
    private_key = file("~/.ssh/id_rsa")  # Provide the path to your private key
    host        = self.public_ip
  }

  tags = {
    Name = "Dev_Server-${count.index + 1}"
  }
}


# Execute Ansible provisioning after creating the instance for production instances
# resource "null_resource" "ansible_provisioner_prod" {
#   count = 2  # Adjusted to match the number of production instances
#   triggers = {
#     instance_id = aws_instance.my_EC2_instances_prod[count.index].id
#   }

#   provisioner "local-exec" {
#     working_dir = "/home/princewillopah/DevOps-World/Ansible/PROJECTS/TF-Ansible-Daynamic-inventory"
#     command = "ansible-playbook my-playbook.yml"
#   }
# }

# Execute Ansible provisioning after creating the instance for development instances
resource "null_resource" "ansible_provisioner_dev" {
  count = 2  # Adjusted to match the number of development instances
  triggers = {
    instance_id = aws_instance.my_EC2_instances_dev[count.index].id
  }

  provisioner "local-exec" {
    working_dir = "/home/princewillopah/DevOps-World/Ansible/PROJECTS/TF-Ansible-Daynamic-inventory"
    command = "ansible-playbook my-playbook.yml"
  }
}

# Output the public IP addresses of the instances
# output "public_ip_addresses_prod" {
#   value = aws_instance.my_EC2_instances_prod[*].public_ip
# }

output "public_ip_addresses_dev" {
  value = aws_instance.my_EC2_instances_dev[*].public_ip
}