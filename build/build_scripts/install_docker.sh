#!/bin/bash

# Install latest docker for debian

set -eu -o pipefail 

echo "Installing Docker ..."

# COnfigure keyring
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Configure docker repos
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian trixie stable" \
  > /etc/apt/sources.list.d/docker.list

# Install and cleanup
apt-get update
apt-get install -y docker-ce-cli docker-compose-plugin
rm -rf /var/lib/apt/lists/*

# Check installation
docker --version

echo "Docker has been installed"
