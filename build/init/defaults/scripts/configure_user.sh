#!/bin/bash

# Configure a given user with custom uid/gid, optionally add ssh keys to user

set -eu -o pipefail

# Configuration check
USERNAME=${1}
PUID=${2}
PGID=${3}
SSH_KEYS=${4:-}


log ()
{
  local level=${1:-DEBUG}
  shift 1
  local msg=${@:-}
  >&2 printf '%6s|%s\n' "$level" "$msg"
}


ensure_user () {
  local username=$1
  local uid=$2
  local gid=$3

  # Ensure user exists
  if ! grep -q "^$username:" /etc/passwd; then
    log INFO "Creating user ($uid/$gid): $username "
    groupadd -g ${gid} ${username}
    local extra_opt=
    [[ -d /home/$username ]] || extra_opt="$extra_opt -m"
    useradd $extra_opt -u ${uid} -g ${gid} -s /bin/bash ${username}
  else

    # Update user UID/GID if changed
    local curr_uid=$(id -u $username)
    local curr_gid=$(id -g $username)
    
    if [ "$curr_uid" != "$uid" ] || [ "$curr_gid" != "$gid" ]; then
      log INFO "Updating user $username uid/gid: $uid/$gid"
      groupmod -g $gid $username 2>/dev/null || true
      usermod -u $uid -g $gid $username 2>/dev/null || true
    else
      log INFO "User $username is already correct ($uid/$gid)"
    fi
  fi

  # Ensure user permissions
  log INFO "Update user home directory permissions ($uid:$gid): /home/$username"
  chown $uid:$gid /home/$username
}

configure_home_permissions() {
  local username=$1
  local uid=$(id -u $username)
  local gid=$(id -g $username)

  log INFO "Recursively update user home directory permissions ($uid:$gid): /home/$username"
  mkdir -p /home/$username
  chown -R $uid:$gid /home/$username
}

configure_authorized_keys () {
  local username=$1
  local uid=$(id -u $username)
  local gid=$(id -g $username)
  local ssh_keys=$2

  local ssh_dir="/home/$username/.ssh"
  mkdir -p "$ssh_dir"

  if [ -n "$ssh_keys" ]; then
    log INFO "Setting up SSH authorized keys..."
    echo "$ssh_keys" | tr ',' '\n' > "$ssh_dir/authorized_keys"
    chmod 700 "$ssh_dir"
    chmod 600 "$ssh_dir/authorized_keys"
  else
    log INFO "No SSH keys to install for user: $username"
  fi

  log INFO "Ensure correct permissions for ssh directory: $ssh_dir"
  chown -R $uid:$gid "$ssh_dir"
}


if [[ -z "$USERNAME" ]]; then
  log ERROR "Missing username argument"
  exit 1
elif [[ "$USERNAME" == 'root' ]]; then
  log WARN "No need to create user root"
  exit 0
fi

#echo "INFO: Configure user $username - Start"
ensure_user $USERNAME $PUID $PGID
# configure_home_permissions $USERNAME
configure_authorized_keys $USERNAME "$SSH_KEYS"
#echo "INFO: Configure user $username - Done"
