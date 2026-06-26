#!/bin/bash

# Install latest docker for debian

set -eu -o pipefail 


# Source OS infos and basic checks
. /etc/os-release
[ "$ID" = "debian" ] || {
  echo "This script only supports Debian" >&2
  exit 1
}

>&2 echo "Installing Docker ..."

# Ensure requirements are available
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  --no-install-recommends \
  ca-certificates \
  curl \
  gnupg

# Configure keyring
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Configure docker repos
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian ${VERSION_CODENAME} stable" \
  > /etc/apt/sources.list.d/docker.list

# Install and cleanup
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce-cli docker-compose-plugin
rm -rf /var/lib/apt/lists/*

# Check installation
docker --version

>&2 echo "Docker has been installed"
