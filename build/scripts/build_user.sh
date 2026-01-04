#!/bin/bash
set -eu -o pipefail

debug () {
  echo "INSTALL JEZ HOME"
  echo $PWD
  id -u
  groups
  echo "INSTALL JEZ HOME EOF"
}

install_homebrew ()
{
  echo "Installing homebrew ..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Install homebrew
  echo >> /home/$app_username/.bashrc
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/$app_username/.bashrc

  # Enable homebrew
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  echo "Homebrew installed and configured"
}

configure_mise () 
{
  echo 'eval "$(/usr/local/bin/mise activate bash)"' >> ~/.bashrc
  echo "Mise installed and configured"
}

final ()
{
  echo "All build tools correctly installed as $app_username"
}

debug
install_homebrew
configure_mise
final

