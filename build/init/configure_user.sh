#!/bin/bash
set -eu -o pipefail

# Configuration check
app_username=${1:-}

if [[ -z "$app_username" ]]; then
  echo "ERROR: Missing username argument"
  exit 1
elif [[ "$app_username" == 'root' ]]; then
  echo "WARN: No need to create user root"
  exit 0
fi


ensure_user () {

  # Ensure user exists
  if ! grep -q "^$app_username:" /etc/passwd; then
    echo "INFO: Creating user $app_username"
    groupadd -g ${app_group_id} ${app_username}
    useradd -m -u ${app_user_id} -g ${app_group_id} -s /bin/bash ${app_username}
  else

    # Update user UID/GID if changed
    CURRENT_UID=$(id -u $app_username)
    CURRENT_GID=$(id -g $app_username)
    
    if [ "$CURRENT_UID" != "$app_user_id" ] || [ "$CURRENT_GID" != "$app_group_id" ]; then
      echo "INFO: Updating user $app_username uid/gid: $app_user_id/$app_group_id"
      groupmod -g $app_group_id $app_username 2>/dev/null || true
      usermod -u $app_user_id -g $app_group_id $app_username 2>/dev/null || true
    else
      echo "INFO: User $app_username is already correct ($app_user_id/$app_group_id)"
    fi
  fi

  # Ensure user permissions
  chown $app_user_id:$app_group_id /home/$app_username
}

configure_home_permissions() {
  echo "INFO: Update user home directory..."
  mkdir -p /home/$app_username
  chown -R $app_user_id:$app_group_id /home/$app_username
}

configure_authorized_keys () {
  local SSH_DIR="/home/$app_username/.ssh"
  mkdir -p "$SSH_DIR"

  if [ -n "$ssh_authorized_keys" ]; then
    echo "INFO: Setting up SSH authorized keys..."
    echo "$ssh_authorized_keys" | tr ',' '\n' > "$SSH_DIR/authorized_keys"
    chmod 700 "$SSH_DIR"
    chmod 600 "$SSH_DIR/authorized_keys"
    chown -R $app_user_id:$app_group_id "$SSH_DIR"
  fi
}


echo "INFO: Configure user $app_username - Start"
ensure_user
#configure_home_permissions
configure_authorized_keys
echo "INFO: Configure user $app_username - Done"
