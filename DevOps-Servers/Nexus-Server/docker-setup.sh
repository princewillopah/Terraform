#!/bin/bash


sleep 120 # wait for 60 secs for the ec2 instance to get from initializing state to running state

sudo apt update -y
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
sudo apt update -y
sudo apt install temurin-17-jdk -y
/usr/bin/java --version


# ##Install Docker and Run SonarQube as Container
sudo apt-get update
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu
newgrp docker
sudo chmod 777 /var/run/docker.sock

sleep 60

docker run -d --name Nexus3 -p 8081:8081 sonatype/nexus3

# # Update package manager repositories and install necessary dependencies
# # Add Docker's official GPG key:
# sudo apt update
# sudo apt install ca-certificates curl
# sudo install -m 0755 -d /etc/apt/keyrings
# sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
# sudo chmod a+r /etc/apt/keyrings/docker.asc

# # Add the repository to Apt sources:
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#   $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
#   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
# sudo apt update

# # To install the latest version, run:
# sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# # Add users to the docker group
# sudo usermod -aG docker ubuntu
# sudo usermod -aG docker jenkins

# # Set permissions for Docker socket
# sudo chmod 777 /var/run/docker.sock

# Create a Docker container running Nexus 3 and expose it on port 8081


