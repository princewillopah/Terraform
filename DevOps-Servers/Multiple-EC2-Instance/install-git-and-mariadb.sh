#!/bin/bash

export DATABASE_PASS='PRINCEWILL1980'
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y git zip unzip mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
cd /tmp/
git clone -b main https://github.com/hkhcoder/vprofile-project.git
sudo mysqladmin -u root password "$DATABASE_PASS"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
sudo mysql -u root -p"$DATABASE_PASS" -e "create database accounts"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'PRINCEWILL1980'"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'%' identified by 'PRINCEWILL1980'"
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
sudo systemctl restart mariadb

# // ==============================================
# // ==============================================


# # Update the package list
# echo "Updating package list..."
# sudo apt-get update -y

# # Install Git and MariaDB server
# echo "Installing Git and MariaDB server..."
# sudo apt-get install git mariadb-server -y

# # Start and enable MariaDB service
# echo "Starting MariaDB service..."
# sudo systemctl start mariadb
# sudo systemctl enable mariadb

# # Verify the installations
# echo "Verifying installations..."
# git --version
# mariadb --version

# echo "Git and MariaDB installation completed successfully!"
# ==========================================================

# wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc
# echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
# sudo apt update -y
# sudo apt install temurin-17-jdk -y
# /usr/bin/java --version
# curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
# echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
# sudo apt-get update -y
# sudo apt-get install jenkins -y
# sudo systemctl start jenkins
# sudo systemctl status jenkins

# # ##Install Docker and Run SonarQube as Container
# sudo apt-get update
# sudo apt-get install docker.io -y
# sudo usermod -aG docker ubuntu
# sudo usermod -aG docker jenkins  
# newgrp docker
# sudo chmod 777 /var/run/docker.sock
# # docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

# #install trivy
# sudo apt-get install wget apt-transport-https gnupg lsb-release -y
# wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
# echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
# sudo apt-get update
# sudo apt-get install trivy -y

# echo 'alias cl="clear"' >> ~/.bashrc