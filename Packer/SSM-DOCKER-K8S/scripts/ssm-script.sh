#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo apt update -y

# Basic packages
sudo apt install -y \
  unzip \
  curl \
  git \
  ca-certificates \
  gnupg \
  lsb-release

# Docker
sudo apt install -y docker.io

# PostgreSQL 16 client — requires the official PGDG repo
# The default Ubuntu repos don't carry postgresql-client-16
sudo install -d /usr/share/postgresql-common/pgdg
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail \
  https://www.postgresql.org/media/keys/ACCC4CF8.asc

sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] \
  https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
  > /etc/apt/sources.list.d/pgdg.list'

sudo apt update -y

sudo apt install -y \
  postgresql-client-common \
  postgresql-client-16

# Enable Docker
sudo systemctl enable docker
sudo systemctl start docker

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify SSM Agent
sudo snap install amazon-ssm-agent --classic || true
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service || true
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service || true

# Cleanup
sudo apt clean