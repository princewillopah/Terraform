#!/bin/bash

# Wait for the instance to initialize
sleep 120

# Update package lists
sudo apt-get update -y

# Install Docker
sudo apt-get install -y docker.io

# Add the current user to the docker group to avoid using sudo with docker commands
sudo usermod -aG docker $USER
newgrp docker
sudo chmod 777 /var/run/docker.sock

# Install Docker Compose
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version

# Restart the docker service to apply group changes
sudo systemctl restart docker
