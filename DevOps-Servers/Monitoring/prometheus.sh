#!/bin/bash

sleep 60 # wait for 60 secs for the ec2 instance to get from initializing state to running state


# Update the system
sudo apt-get update
sudo apt-get upgrade -y

# Create a Prometheus group and user
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus ## user prometheus will not have access to login. its just there to start up the process

# Create the following forders
sudo mkdir -p /var/lib/prometheus   # here is going to store data e.g the time-series data etc
sudo mkdir -p /etc/prometheus/rules 
sudo mkdir -p /etc/prometheus/rules.s
sudo mkdir -p /etc/prometheus/files_sd



# Download the latest version of Prometheus
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.54.0/prometheus-2.54.0.linux-amd64.tar.gz

# Extract the downloaded tarball and delete the tar file
sudo tar xvf prometheus-2.54.0.linux-amd64.tar.gz  
sudo rm -rf prometheus-2.54.0.linux-amd64.tar.gz

# Move Prometheus binaries to /usr/local/bin
cd prometheus-2.54.0.linux-amd64 ## this dir contains prometheus promtool console console_libraries prometheus.yml etc
sudo mv prometheus promtool  /usr/local/bin/
# at this point you can confirm the installation to indicate that prometheus is accessible and can be executed by running "prometheus --version"

# Move Prometheus binaries to /usr/local/bin
sudo mv console console_libraries  /etc/prometheus

# Move Prometheus binaries to /usr/local/bin
sudo mv prometheus.yml /etc/prometheus/prometheus.yml  # copy the file



# let the prometheus user be the owner of the following moved dirs console_libraries & console
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/*
sudo chmod -R 775 /etc/prometheus/
sudo chmod -R 775 /etc/prometheus/*
# sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
# sudo chown -R prometheus:prometheus /etc/prometheus/console
# let the prometheus user be the owner of the following dirs

# let the prometheus user be the owner of the following moved dirs prometheus & promtool
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml  # change owner

# Create a systemd service file for Prometheus
sudo bash -c 'cat <<EOL > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOL'



# Reload systemd and start Prometheus
sudo systemctl daemon-reload  ## restat the daemon since we updated its files
sudo systemctl start prometheus  # start the process
sudo systemctl enable prometheus  # also start automatically on boot