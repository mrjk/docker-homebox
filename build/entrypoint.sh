#!/bin/bash
set -e

# Default values
app_username=${app_username:-appuser}
app_user_id=${app_user_id:-1000}
app_group_id=${app_group_id:-1000}

echo "=== Container Initialization ==="
echo "User: $app_username (UID: $app_user_id, GID: $app_group_id)"

# Update user UID/GID if changed
CURRENT_UID=$(id -u $app_username)
CURRENT_GID=$(id -g $app_username)

if [ "$CURRENT_UID" != "$app_user_id" ] || [ "$CURRENT_GID" != "$app_group_id" ]; then
    echo "Updating user UID/GID..."
    groupmod -g $app_group_id $app_username 2>/dev/null || true
    usermod -u $app_user_id -g $app_group_id $app_username 2>/dev/null || true
fi

# Fix permissions on home directory
echo "Fixing home directory permissions..."
chown -R $app_user_id:$app_group_id /home/$app_username

# Generate SSH host keys if they don't exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    echo "Generating SSH host keys..."
    ssh-keygen -A
fi

# Setup SSH authorized_keys
SSH_DIR="/home/$app_username/.ssh"
mkdir -p "$SSH_DIR"

if [ -n "$ssh_authorized_keys" ]; then
    echo "Setting up SSH authorized keys..."
    echo "$ssh_authorized_keys" | tr ',' '\n' > "$SSH_DIR/authorized_keys"
    chmod 700 "$SSH_DIR"
    chmod 600 "$SSH_DIR/authorized_keys"
    chown -R $app_user_id:$app_group_id "$SSH_DIR"
fi

# Fix docker permissions for regular user
DOCKER_SOCK="/var/run/docker.sock"
if [ -S "$DOCKER_SOCK" ]; then
    DOCKER_GID=$(stat -c '%g' "$DOCKER_SOCK")

    if ! getent group docker >/dev/null; then
        groupadd -g "$DOCKER_GID" docker
    else
        groupmod -g "$DOCKER_GID" docker
    fi

    usermod -aG docker $app_username
fi


# Parse init.ini config file
if [ -f /etc/init.ini ]; then
    echo "Reading init.ini configuration..."
    
    # Read startup commands
    if grep -q "^\[startup\]" /etc/init.ini; then
        echo "Executing startup commands..."
        sed -n '/^\[startup\]/,/^\[/p' /etc/init.ini | grep -v '^\[' | grep -v '^#' | grep -v '^$' | while read -r cmd; do
            if [ -n "$cmd" ]; then
                echo "  Running: $cmd"
                eval "$cmd" || echo "  Warning: Command failed: $cmd"
            fi
        done
    fi
    
    # Read services to start
    if grep -q "^\[services\]" /etc/init.ini; then
        echo "Starting configured services..."
        sed -n '/^\[services\]/,/^\[/p' /etc/init.ini | grep -v '^\[' | grep -v '^#' | grep -v '^$' | while read -r service; do
            if [ -n "$service" ]; then
                echo "  Starting service: $service"
                eval "$service &" || echo "  Warning: Service failed: $service"
            fi
        done
    fi
fi

# Keep container running
echo "=== Initialization Complete ==="
echo "SSH is running on port 22"
echo "Connect with: ssh -p <mapped-port> $app_username@localhost"
echo "Current routing table"
ip route

set -x

echo "Container waiting for infinity ..."
/usr/bin/sleep infinity

echo "Quitting container!"

# Wait for all background processes
