#!/bin/bash

# # Update package list
apt-get update -y


# apt-get install -y amazon-ssm-agent
# systemctl enable amazon-ssm-agent
# systemctl start amazon-ssm-agent

### or 

# Install snapd if missing
apt-get install -y snapd

# Install SSM agent
snap install amazon-ssm-agent --classic

# Enable & start agent
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

# Optional: verify
systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service