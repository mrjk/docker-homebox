#!/bin/bash
# Give docker socket permission for a given user
set -eu -o pipefail

USERNAME=$1

log ()
{
  local level=${1:-DEBUG}
  shift 1
  local msg=${@:-}
  >&2 printf '%6s|%s\n' "$level" "$msg"
}


configure_docker_perms () {
  local user=$1
  local DOCKER_SOCK="/var/run/docker.sock"

  # Check docker socket exists
  if ! [ -S "$DOCKER_SOCK" ]; then
    log WARN "Can't add user '$user' to docker group since docker socket is not available: $DOCKER_SOCK"
    return 0
  fi

  # Create docker if not present
  local DOCKER_GID=$(stat -c '%g' "$DOCKER_SOCK")
  if ! getent group docker >/dev/null; then
      groupadd -g "$DOCKER_GID" docker
      log DEBUG "Create 'docker' group with gid: $DOCKER_GID"
  else
      groupmod -g "$DOCKER_GID" docker
      log DEBUG "Modify 'docker' group with gid: $DOCKER_GID"
  fi

  # Add user to docker group
  usermod -aG docker $user
  log INFO "Add user '$user' to docker group (gid:$DOCKER_GID) for socket access: $DOCKER_SOCK"
}

configure_docker_perms "$USERNAME"

