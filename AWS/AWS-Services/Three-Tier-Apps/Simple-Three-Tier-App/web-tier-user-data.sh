#!/bin/bash
# exec > >(tee /var/log/user-data.log) 2>&1
# set -e

# ------------------------------------------------------------------
# Non-interactive & safe defaults
# ------------------------------------------------------------------
# export DEBIAN_FRONTEND=noninteractive
# export HOME=/root

# ------------------------------------------------------------------
# System update (NO apt upgrade in cloud-init)
# ------------------------------------------------------------------
apt update -y

# ------------------------------------------------------------------
# Swap (critical for frontend builds on small EC2)
# ------------------------------------------------------------------
# if ! swapon --show | grep -q swapfile; then
#   fallocate -l 2G /swapfile
#   chmod 600 /swapfile
#   mkswap /swapfile
#   swapon /swapfile
# fi

# ------------------------------------------------------------------
# Base packages
# ------------------------------------------------------------------
apt install -y curl ca-certificates gnupg git nginx

# ------------------------------------------------------------------
# Node.js 18 (NodeSource) + npm
# ------------------------------------------------------------------
# curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs npm

# ------------------------------------------------------------------
# Hard verification (fail fast)
# ------------------------------------------------------------------
node -v
npm -v
nginx -v

# ------------------------------------------------------------------
# Application setup
# ------------------------------------------------------------------
cd /home/ubuntu

# if [ ! -d Test-Apps ]; then
  git clone https://github.com/princewillopah/Test-Apps.git
# fi

cd Test-Apps/Shopsphere-Ecommerce-Containerized/frontend

# ------------------------------------------------------------------
# Frontend build
# ------------------------------------------------------------------
npm install
npm run build

# ------------------------------------------------------------------
# Deploy build to Nginx
# ------------------------------------------------------------------
rm -rf /var/www/shopsphere
mkdir -p /var/www/shopsphere
cp -r dist/* /var/www/shopsphere/

# ------------------------------------------------------------------
# Nginx configuration (use your repo's nginx.conf)
# ------------------------------------------------------------------
cp nginx.conf /etc/nginx/sites-available/shopsphere
ln -sf /etc/nginx/sites-available/shopsphere /etc/nginx/sites-enabled/shopsphere
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl enable nginx
systemctl restart nginx
