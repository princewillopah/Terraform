#!/bin/bash

sleep 30 # wait for 60 secs for the ec2 instance to get from initializing state to running state


##Install Docker and Run SonarQube as Container
sudo apt-get update
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu
newgrp docker
sudo chmod 777 /var/run/docker.sock
sudo systemctl start docker
sudo systemctl enable docker
docker images


sleep 10 # wait for 30 secs for the ec2 instance to get from initializing state to running state

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

sleep 10 # wait for 30 secs for the ec2 instance to get from initializing state to running state

mkdir -p /home/ubuntu/NewPush
touch /home/ubuntu/NewPush/.env /home/ubuntu/NewPush/docker-compose.yml
echo "you are good to go"