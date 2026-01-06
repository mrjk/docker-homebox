#!/bin/bash
set -eu -o pipefail

app_username=$1

configure_docker_perms () {
  local DOCKER_SOCK="/var/run/docker.sock"
  if [ -S "$DOCKER_SOCK" ]; then
    local DOCKER_GID=$(stat -c '%g' "$DOCKER_SOCK")

    if ! getent group docker >/dev/null; then
        groupadd -g "$DOCKER_GID" docker
    else
        groupmod -g "$DOCKER_GID" docker
    fi

    usermod -aG docker $app_username
  fi
}

echo "INFO: Configuring user $app_username with docker"
configure_docker_perms
echo "INFO: Configuring user $app_username with docker - Done"

