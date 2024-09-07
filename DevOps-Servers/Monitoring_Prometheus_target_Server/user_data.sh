#!/bin/bash

sleep 60 # wait for 60 secs for the EC2 instance to get from initializing state to running state

# Update the system
sudo apt-get update
sudo apt-get upgrade -y

# Create a Node Exporter group and user
sudo groupadd --system node_exporter_user
sudo useradd -s /sbin/nologin --system -g node_exporter_user node_exporter_user # user node_exporter will not have access to login. it's just there to start up the process

# Create the following folders
sudo mkdir -p /var/lib/node_exporter
sudo mkdir -p /etc/node_exporter

# Download the latest version of Node Exporter
sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

# Extract the downloaded tarball and delete the tar file
sudo tar xvf node_exporter-1.8.2.linux-amd64.tar.gz
sudo rm -rf node_exporter-1.8.2.linux-amd64.tar.gz

# Move Node Exporter binary to /usr/local/bin
cd node_exporter-1.8.2.linux-amd64  ## this contains  node_exporter
sudo mv node_exporter /usr/local/bin/
sudo chown node_exporter_user:node_exporter_user  /usr/local/bin/node_exporter

# Create a systemd service file for Node Exporter
sudo bash -c 'cat <<EOL > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter_user
Group=node_exporter_user
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOL'

# Reload systemd and start Node Exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter