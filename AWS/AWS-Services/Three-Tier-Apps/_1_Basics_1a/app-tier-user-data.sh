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

git clone https://github.com/princewillopah/Test-Apps.git
cd Test-Apps/Shopsphere-Ecommerce-Containerized/backend

# ------------------------------------------------------------------
# Frontend build
# ------------------------------------------------------------------
npm install

# ------------------------------------------------------------------
# create .env file
# ------------------------------------------------------------------
cat <<EOF > .env
NODE_ENV=production
PORT=5000
MONGO_URI=mongodb://${mongodb_private_ip}:27017/shopsphere
JWT_SECRET=replace_with_real_secret
EOF

# ------------------------------------------------------------------
# Process manager setup (PM2)
# # ------------------------------------------------------------------
# npm install -g pm2

# # ------------------------------------------------------------------
# # Nginx configuration (use your repo's nginx.conf)
# # ------------------------------------------------------------------
# pm2 start server.js --name shopsphere-backend
# pm2 startup systemd -u ubuntu --hp /home/ubuntu
# pm2 save

# nginx -t
# systemctl enable nginx
# systemctl restart nginx
