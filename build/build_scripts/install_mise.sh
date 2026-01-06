#!/bin/bash

# Install latest docker for debian

set -eu -o pipefail

echo "Installing mise ..."
# Install mise
export MISE_CACHE_DIR="/cache/mise"
export MISE_INSTALL_PATH="/usr/local/bin/mise"
mkdir -p $MISE_CACHE_DIR ${MISE_INSTALL_PATH%/*}
curl https://mise.run | sh

[ -f /usr/local/bin/mise ] || {
  echo "Fail to install mise "
  exit 1
}
/usr/local/bin/mise --version 

# Enable mise
#echo 'eval "$(/usr/local/bin/mise activate bash)"' >> ~/.bashrc

echo "Mise installed and configured"

