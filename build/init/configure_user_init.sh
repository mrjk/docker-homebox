#!/bin/bash
set -eu -o pipefail

# Configuration check
app_username=${1:-root}

if [[ -z "$app_username" ]]; then
  echo "ERROR: Missing username argument"
  exit 1
fi

run_user_init ()
{
  local user=$1
  local home=$(getent passwd "$app_username" | cut -d: -f6)
  local config_dir="$home/.config/homebox"
  local script_path="$config_dir/init.sh"

  if [[ -f "$script_path" ]]; then
    echo "Run user $user init script: $script_path"
    su $user $script_path
  else
    echo "No init script found in $script_path"
  fi
}

echo "INFO: Run user $app_username init script - Start"
run_user_init $app_username
echo "INFO: Run user $app_username init script - Done"
