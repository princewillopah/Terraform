#!/bin/bash

# Update OS
apt update -y

# Install nginx + git
apt install -y nginx git

# Clean web directory
rm -rf /var/www/html/*

# Clone to temp directory
git clone https://github.com/princewillopah/html-website-sample.git /tmp/html-website-sample

# Move website files
cp -r /tmp/html-website-sample/* /var/www/html/

# Fix permissions
chown -R www-data:www-data /var/www/html

# Cleanup
rm -rf /tmp/html-website-sample

# Enable + restart Nginx
systemctl enable nginx
systemctl restart nginx

