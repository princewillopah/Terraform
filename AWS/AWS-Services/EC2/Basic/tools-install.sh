#!/bin/bash

# Update package list
apt-get update -y

# Install SSM Agent (Snap method)
snap install amazon-ssm-agent --classic

# Enable and start SSM agent
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

# Optional: verify status
systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service