#!/bin/bash

# Log the output of the script
exec > >(tee -i /var/log/user-data.log)
exec 2>&1
# cd /var/log/ && cat user-data.log

# Wait for the instance to stabilize
sleep 60

# Update and install required software
sudo apt-get update -y
sudo apt-get install -y software-properties-common

# Add Ansible PPA and install Ansible
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get update -y
sudo apt-get install -y ansible

# Install Git
sudo apt-get install -y git

# Create Ansible directory and navigate into it
mkdir -p /home/ubuntu/Ansible
cd /home/ubuntu/Ansible

# Clone the repository
if git clone https://github.com/princewillopah/Ansible.git; then
  echo "Git repository cloned successfully."
else
  echo "Failed to clone the Git repository." >&2
  exit 1
fi

# Navigate to the directory containing the Ansible playbook
cd Ansible/server-installations-configuration || { echo "Directory not found"; exit 1; }

# Run the Ansible playbook
if ansible-playbook -i localhost ansible-configuration-2.yml; then
  echo "Ansible playbook executed successfully."
else
  echo "Ansible playbook failed." >&2
  exit 1
fi



# =====================================================
#  old script
# =====================================================
# sleep 60

# exec > >(tee -i /var/log/user-data.log)
# exec 2>&1
# sudo apt update -y
# sudo apt install software-properties-common
# sudo add-apt-repository --yes --update ppa:ansible/ansible
# sudo apt install ansible -y
# sudo apt install git -y 
# mkdir Ansible && cd Ansible ## make this "Ansible" dirctory in the newly provisioned Jenkins Instance
# pwd
# git clone https://github.com/princewillopah/Ansible.git #this has to be externally since the server is new
# cd Ansible/server-installations-configuration  # this is where DevSecOps.yml is located.
# ansible-playbook -i localhost Ansible-configuration-2.yml






