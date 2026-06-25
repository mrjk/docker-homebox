#!/bin/bash
# Script that look into a user home and execute a defined script if it exists.

set -eu -o pipefail
USERNAME=${1:-root}

log ()
{
  local level=${1:-DEBUG}
  shift 1
  local msg=${@:-}
  >&2 printf '%6s|%s\n' "$level" "$msg"
}


run_user_init ()
{
  local user=$1
  local home=$(getent passwd "$user" | cut -d: -f6)
  local config_dir="$home/.config/homebox"
  local script_path="$config_dir/init.sh"

  if [[ -f "$script_path" ]]; then
    log INFO "Run user '$user' init script from: $script_path"
    su $user $script_path
  else
    log INFO "No user startup config since file is absent: $script_path"
  fi
}

run_user_init $USERNAME
