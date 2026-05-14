### Install Packer

Ubuntu / WSL
```yaml
sudo apt update
sudo apt install -y wget unzip

wget https://releases.hashicorp.com/packer/1.12.0/packer_1.12.0_linux_amd64.zip
unzip packer_1.12.0_linux_amd64.zip
sudo mv packer /usr/local/bin/

packer version
```