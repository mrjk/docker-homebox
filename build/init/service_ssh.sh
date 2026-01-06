#!/bin/bash
set -eu -o pipefail


ensure_ssh_host_keys () {
  # Generate SSH host keys if they don't exist
  if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    echo "Generating SSH host keys..."
    ssh-keygen -A
  fi
}

ensure_ssh_config () {
  if [ ! -f /etc/ssh/sshd_config ]; then
    echo "Recreating sshd configuration ..."

    # Use backuped config or reuse apt to reconfigure
    if [[ -d /usr/local/include/confs/ssh/ ]]; then
      cp -a --update=none /usr/local/include/confs/ssh/ /etc/ssh/
    else
      apt update
      apt-get -o Dpkg::Options::="--force-confmiss" install --reinstall openssh-server
    fi
  fi
}

start_sshd () {
  /usr/sbin/sshd -D
}

echo "Starting openssh-server service"
ensure_ssh_config
ensure_ssh_host_keys
start_sshd
echo "Starting openssh-server service - Exited $?"

