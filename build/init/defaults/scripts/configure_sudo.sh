#!/bin/bash

# Configure a given user with custom uid/gid, optionally add ssh keys to user

set -eu -o pipefail

# Configuration check
USERNAME=${1}

log ()
{
  local level=${1:-DEBUG}
  shift 1
  local msg=${@:-}
  >&2 printf '%6s|%s\n' "$level" "$msg"
}

ensure_sudo () {
  local username=$1
  log INFO "Enabling passwordless sudo for user: $username"
  echo "${username} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${username} && \
    chmod 0440 /etc/sudoers.d/${username}

}


if [[ -z "$USERNAME" ]]; then
  log ERROR "Missing username argument"
  exit 1
elif [[ "$USERNAME" == 'root' ]]; then
  log WARN "Can't add root user to sudoers"
  exit 0
fi

ensure_sudo $USERNAME
