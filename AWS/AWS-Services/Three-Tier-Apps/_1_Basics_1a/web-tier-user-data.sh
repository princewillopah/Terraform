#!/bin/bash

set -u

exec > /var/log/user-data.log 2>&1

echo "Waiting for network..."

sleep 30
# ------------------------------------------------------------------
# Non-interactive & safe defaults
# ------------------------------------------------------------------
# export DEBIAN_FRONTEND=noninteractive
# export HOME=/root

# ------------------------------------------------------------------
# System update (NO apt upgrade in cloud-init)
# ------------------------------------------------------------------

apt-get update -y

# ------------------------------------------------------------------
# Base packages
# ------------------------------------------------------------------
apt-get install -y curl gnupg nginx git

# ------------------------------------------------------------------
# Node.js 18 (NodeSource) + npm
# ------------------------------------------------------------------


echo "Adding NodeSource repo..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash - || {
  echo "NodeSource setup failed"
  exit 1
}

apt-get update -y
apt-get install -y nodejs

node -v
npm -v
nginx -v

#
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
