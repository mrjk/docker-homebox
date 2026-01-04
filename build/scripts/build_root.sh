#!/bin/bash
set -eu -o pipefail

debug () {
  echo "INSTALL ROOT HOME"
  echo $PWD
  id -u
  groups
  echo "INSTALL ROOT HOME EOF"
}

install_omb ()
{

  echo "Installing ohmybash ..."
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --prefix=/usr --unattended

  echo "omybash installed and configured"
}

install_mise ()
{
  echo "Installing mise ..."
  # Install mise
  #export MISE_DATA_DIR="/mise"
  #export MISE_CONFIG_DIR="/mise"
  #export MISE_CACHE_DIR="/mise/cache"
  export MISE_INSTALL_PATH="/usr/local/bin/mise"
  #export PATH="/mise/shims:$PATH"
  # ENV MISE_VERSION="..."
  curl https://mise.run | sh

  [ -f /usr/local/bin/mise ] || {
    echo "Fail to install mise "
    return 1
  }

  # Enable mise
  echo 'eval "$(/usr/local/bin/mise activate bash)"' >> ~/.bashrc

  echo "Mise installed and configured"
}

final ()
{
  echo "All build tools correctly installed as root"
}

debug
install_mise
install_omb
final

