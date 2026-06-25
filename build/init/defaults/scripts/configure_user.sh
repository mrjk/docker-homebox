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
  local home_dir=

  # Ensure user exists
  if ! grep -q "^$username:" /etc/passwd; then
    log INFO "Creating user ($uid/$gid): $username "
    groupadd -g ${gid} ${username}
    local extra_opt=
    home_dir=/home/$username
    [[ -d "$home_dir" ]] || extra_opt="$extra_opt -m"
    useradd $extra_opt -u ${uid} -g ${gid} -s /bin/bash ${username}
  else
    
    home_dir=$(getent passwd "$username" | cut -d: -f6)

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
  log INFO "Update user home directory permissions ($uid:$gid): $home_dir"
  chown $uid:$gid "$home_dir"
}

configure_home_permissions() {
  local username=$1
  local uid=$(id -u $username)
  local gid=$(id -g $username)
  local home_dir=$(getent passwd "$username" | cut -d: -f6)

  log INFO "Recursively update user home directory permissions ($uid:$gid): $home_dir"
  mkdir -p "$home_dir"
  chown -R $uid:$gid "$home_dir"
}

parse_ssh_keys () {
  local ssh_keys=$1

  echo "$ssh_keys" | tr ',' '\n' | while IFS= read -r line; do
    # Trim leading/trailing whitespace
    line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  
    if [[ "$line" == http://* ]] || [[ "$line" == https://* ]]; then
      # Download the file, strip empty lines, append to authorized_keys
      curl -fsSL "$line" | grep -v '^[[:space:]]*$' >> "$ssh_dir/authorized_keys"
    else
      # Regular key — skip empty lines, append to authorized_keys
      if [[ -n "$line" ]]; then
        echo "$line"
      fi
    fi
  done
}

configure_authorized_keys () {
  local username=$1
  local uid=$(id -u $username)
  local gid=$(id -g $username)
  local ssh_keys=$2

  local home_dir=$(getent passwd "$username" | cut -d: -f6)
  local ssh_dir="$home_dir/.ssh"
  mkdir -p "$ssh_dir"

  if [ -n "$ssh_keys" ]; then
    log INFO "Setting up SSH authorized keys..."
    # echo "$ssh_keys" | tr ',' '\n' > "$ssh_dir/authorized_keys"
    parse_ssh_keys "$ssh_keys" > "$ssh_dir/authorized_keys"
    chmod 700 "$ssh_dir"
    chmod 600 "$ssh_dir/authorized_keys"
  else
    log INFO "No SSH keys to install for user: $username"
  fi

  log INFO "Ensure correct permissions for ssh directory: $ssh_dir"
  chown -R $uid:$gid "$ssh_dir"
}


allow_passwordless_root () {
  log INFO "Allow passwordless ssh for root user"
  sed -i \
    -e 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' \
    /etc/ssh/sshd_config
  
  # -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' \
}

if [[ -z "$USERNAME" ]]; then
  log ERROR "Missing username argument"
  exit 1
fi

if [[ "$USERNAME" != 'root' ]]; then
  ensure_user $USERNAME $PUID $PGID
else
  log WARN "No need to create user root"
  allow_passwordless_root
fi

configure_authorized_keys $USERNAME "$SSH_KEYS"


