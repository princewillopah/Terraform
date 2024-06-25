#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Update the package list
echo "Updating package list..."
sudo apt-get update -y

# Install Memcached
echo "Installing Memcached..."
sudo apt-get install memcached -y

# Configure Memcached to listen on port 11211
echo "Configuring Memcached to listen on port 11211..."
sudo sed -i 's/-l 127.0.0.1/-l 0.0.0.0/' /etc/memcached.conf
sudo sed -i 's/-p 11211/-p 11211/' /etc/memcached.conf

# Restart Memcached to apply changes
echo "Restarting Memcached service..."
sudo systemctl restart memcached

# Enable Memcached to start on boot
echo "Enabling Memcached service to start on boot..."
sudo systemctl enable memcached

# Verify the installation and configuration
echo "Verifying Memcached installation and configuration..."
memcached -V
sudo ss -plnt | grep 11211

echo "Memcached installation and configuration completed successfully!"



# wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc
# echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
# sudo apt update -y
# sudo apt install temurin-17-jdk -y
# /usr/bin/java --version
# curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
# echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
# sudo apt-get update -y
# sudo apt-get install jenkins -y
# sudo systemctl start jenkins
# sudo systemctl status jenkins
# ///////////////////////////////////////////////////////////
# # ##Install Docker and Run SonarQube as Container
# sudo apt-get update
# sudo apt-get install docker.io -y
# sudo usermod -aG docker ubuntu
# sudo usermod -aG docker jenkins  
# newgrp docker
# sudo chmod 777 /var/run/docker.sock
# # docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

# #install trivy
# sudo apt-get install wget apt-transport-https gnupg lsb-release -y
# wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
# echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
# sudo apt-get update
# sudo apt-get install trivy -y

# echo 'alias cl="clear"' >> ~/.bashrc