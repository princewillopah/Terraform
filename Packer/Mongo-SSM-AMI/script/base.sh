#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y curl gnupg unzip ca-certificates lsb-release

# Disable unattended upgrades (AMI best practice)
systemctl disable unattended-upgrades || true