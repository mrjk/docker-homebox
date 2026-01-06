#!/bin/bash
set -eu -o pipefail


if [[ -n "$HOMEBOX_USER_LOGIN" ]]; then

  if [[ "$HOMEBOX_USER_LOGIN" == 'root' ]]; then
    echo "WARN: No need to create user root"
    exit 0
  fi

  echo "Configuration service for user: $HOMEBOX_USER_LOGIN - Starting"
  /usr/local/init/configure_user.sh $HOMEBOX_USER_LOGIN
  /usr/local/init/configure_docker.sh $HOMEBOX_USER_LOGIN
  /usr/local/init/configure_user_init.sh $HOMEBOX_USER_LOGIN
  echo "Configuration service for user: $HOMEBOX_USER_LOGIN - Done"

fi




