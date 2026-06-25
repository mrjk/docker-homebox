#!/bin/bash
set -eu -o pipefail

log ()
{
  local level=${1:-DEBUG}
  shift 1
  local msg=${@:-}
  >&2 printf '%6s|%s\n' "$level" "$msg"
}


if [[ -n "$HOMEBOX_USER_LOGIN" ]]; then


  log INFO "Configure dynamic user: $HOMEBOX_USER_LOGIN"
  configure_user.sh $HOMEBOX_USER_LOGIN $HOMEBOX_USER_UID $HOMEBOX_USER_GID "${HOMEBOX_USER_PUBKEYS}"

  if [[ "$HOMEBOX_USER_LOGIN" != 'root' ]]; then

    configure_docker.sh $HOMEBOX_USER_LOGIN
    if [[ "$HOMEBOX_USER_SUDO" == true ]]; then
      configure_sudo.sh $HOMEBOX_USER_LOGIN
    else
      log INFO "Skipping sudo config for: $HOMEBOX_USER_LOGIN"
    fi
  else
    log INFO "Skip user permissions scripts"

  fi

  run_user_init.sh $HOMEBOX_USER_LOGIN
fi




