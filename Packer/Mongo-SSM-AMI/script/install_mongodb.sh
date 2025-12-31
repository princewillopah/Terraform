#!/bin/bash
set -euxo pipefail

curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
  gpg --dearmor -o /usr/share/keyrings/mongodb-server.gpg

echo "deb [ signed-by=/usr/share/keyrings/mongodb-server.gpg ] \
https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" \
> /etc/apt/sources.list.d/mongodb-org.list

apt-get update -y
apt-get install -y mongodb-org

# DO NOT start MongoDB in the AMI
systemctl disable mongod
systemctl stop mongod || true

# Security default: localhost only
sed -i 's/^  bindIp:.*/  bindIp: 127.0.0.1/' /etc/mongod.conf

systemctl restart mongod

echo "MongoDB installation complete"
# Install MySQL (scripts/install_mysql.sh
# #!/bin/bash
# set -euxo pipefail

# apt-get install -y mysql-server

# # Stop and disable for AMI
# systemctl stop mysql
# systemctl disable mysql

# # Bind locally by default
# sed -i 's/^bind-address.*/bind-address = 127.0.0.1/' /etc/mysql/mysql.conf.d/mysqld.cnf
