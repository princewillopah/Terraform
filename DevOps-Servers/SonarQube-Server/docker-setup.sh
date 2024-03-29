#!/bin/bash
set -e  # to immediately exit if any command returns a non-zero exit status, indicating an error. 

# Update package manager repositories and install necessary dependencies
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
sudo apt update

# To install the latest version, run:
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add users to the docker group
sudo usermod -aG docker ubuntu
# sudo usermod -aG docker jenkins

# Set permissions for Docker socket
sudo chmod 777 /var/run/docker.sock

# Create a Docker container running Nexus 3 and expose it on port 8081
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

