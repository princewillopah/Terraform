#!/bin/bash
set -eux

export DEBIAN_FRONTEND=noninteractive

# Disable command-not-found apt hook (causes failures in Packer)
sudo rm -f /etc/apt/apt.conf.d/20command-not-found || true

sudo apt-get update -y
sudo apt-get install -y curl gnupg unzip

# Install SSM via snap
sudo snap install amazon-ssm-agent --classic

# Start via snapctl
sudo snap start amazon-ssm-agent






# #!/bin/bash
# set -eux

# export DEBIAN_FRONTEND=noninteractive

# sudo apt-get update -y
# sudo apt-get install -y curl gnupg unzip

# # Install SSM via snap
# sudo snap install amazon-ssm-agent --classic

# # Start via snapctl, NOT systemctl
# sudo snap start amazon-ssm-agent

