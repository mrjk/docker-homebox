#!/bin/bash
set -eu -o pipefail

log ()
{
  local level=${1:-DEBUG}
  shift 1
  local msg=${@:-}
  >&2 printf '%6s|%s\n' "$level" "$msg"
}


ensure_ssh_host_keys () {
  # Generate SSH host keys if they don't exist
  if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    log INFO "Generating SSH host keys..."
    ssh-keygen -A
  fi
}

ensure_ssh_config () {
  if [ ! -f /etc/ssh/sshd_config ]; then
    log WARN "OpenSSH server configuration is absent"

    # Use backuped config or reuse apt to reconfigure
    if [[ -d /usr/local/include/confs/ssh/ ]]; then
      log INFO "Include default sshd config from core image"
      cp -ar --update=none /usr/local/include/confs/ssh/ /etc/
    else
      log INFO "Regenerating sshd config"
      apt update
      apt-get -o Dpkg::Options::="--force-confmiss" install --reinstall openssh-server
    fi
  fi
}

start_sshd () {
  /usr/sbin/sshd -D
}

ensure_ssh_config
ensure_ssh_host_keys

log INFO "OpenSSH completely configured"

# TODO
#echo "Starting openssh-server service"
#start_sshd
#echo "Starting openssh-server service - Exited $?"

