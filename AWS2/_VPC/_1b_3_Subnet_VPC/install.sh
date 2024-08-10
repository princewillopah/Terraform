#!/bin/bash

sleep 120 # wait for 2 mins for the ec2 instance to get from initializing state to running state

# Install Docker and run SonarQube as container
sudo apt-get update -y
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu 
newgrp docker
sudo chmod 777 /var/run/docker.sock

# Install Apache
sudo apt-get install apache2 -y

# Enable and start Apache service
sudo systemctl enable apache2
sudo systemctl start apache2

# Display server details for monitoring
ip_address=$(hostname -I | awk '{print $1}')
hostname=$(hostname)
echo "Server IP Address: $ip_address" | sudo tee /var/www/html/index.html
echo "Server Hostname: $hostname" | sudo tee -a /var/www/html/index.html

# Install kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.0/2024-01-04/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin

# Install AWS CLI
sudo apt-get update -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install --update

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Verify installations
aws --version 
kubectl version --client
eksctl version



echo 'alias cl="clear"' >> ~/.bashrc