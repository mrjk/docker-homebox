# SSH and Dynamic User Configuration

This container image can automatically:

* Configure and start an OpenSSH server.
* Create a non-root user at startup.
* Install SSH public keys.
* Grant optional passwordless sudo access.
* Grant Docker socket access when Docker is available.
* Execute user-specific initialization scripts.

All configuration is performed through environment variables.

# Quick Start

Create a user named `john` with UID/GID `1000`, install SSH keys, and enable sudo:

```bash
docker run -d \
  -p 2222:22 \
  -e HOMEBOX_USER_LOGIN=john \
  -e HOMEBOX_USER_UID=1000 \
  -e HOMEBOX_USER_GID=1000 \
  -e HOMEBOX_USER_SUDO=true \
  -e HOMEBOX_USER_PUBKEYS="ssh-ed25519 AAAAC3NzaC1...,https://github.com/john.keys" \
  my-image
```

Connect:

```bash
ssh john@host -p 2222
```

# Environment Variables

## HOMEBOX_USER_LOGIN

Username to create during container startup.

Default:

```bash
HOMEBOX_USER_LOGIN=user
```

Example:

```bash
HOMEBOX_USER_LOGIN=john
```

Special case:

```bash
HOMEBOX_USER_LOGIN=root
```

When set to `root`, no additional user is created.

## HOMEBOX_USER_UID

User UID. Ignored when user is root.

Default:

```bash
HOMEBOX_USER_UID=1000
```

Example:

```bash
HOMEBOX_USER_UID=2000
```

Useful when matching ownership of bind-mounted host directories.

## HOMEBOX_USER_GID

User primary group ID. Ignored when user is root.

Default:

```bash
HOMEBOX_USER_GID=1000
```

Example:

```bash
HOMEBOX_USER_GID=2000
```

## HOMEBOX_USER_PUBKEYS

Comma-separated list of SSH public keys and/or URLs.

Supported formats:

```bash
HOMEBOX_USER_PUBKEYS="ssh-ed25519 AAAA...,https://github.com/john.keys"
```

Each URL is downloaded during startup and appended to the user's `authorized_keys` file.

## HOMEBOX_USER_SUDO

Enable passwordless sudo. Ignored when user is root.

Default:

```bash
HOMEBOX_USER_SUDO=false
```

Enable:

```bash
HOMEBOX_USER_SUDO=true
```

This creates:

```text
/etc/sudoers.d/<username>
```

with:

```text
<username> ALL=(ALL) NOPASSWD:ALL
```

# SSH Server

The container automatically configures OpenSSH.

Startup actions:

1. Verify `/etc/ssh/sshd_config` exists.
2. Restore default configuration if missing.
3. Generate host keys when absent.
4. Start `sshd` under Supervisor.

The SSH daemon runs as root and stays in the foreground:

```bash
/usr/sbin/sshd -D -e
```

Logs are written to container stdout/stderr.

# Dynamic User Management

At startup the container:

1. Creates the configured user if it does not exist.
2. Creates the primary group.
3. Updates UID/GID if already present.
4. Creates the home directory when necessary.
5. Installs SSH authorized keys.
6. Fixes ownership of the home directory.

Example resulting account:

```text
Username: john
UID:      1000
GID:      1000
Home:     /home/john
Shell:    /bin/bash
```

# Docker Socket Access

If a Docker socket is mounted:

```text
/var/run/docker.sock
```

the startup process will:

1. Detect the socket GID.
2. Create or update a `docker` group with the correct GID.
3. Add the configured user to that group.

Example:

```bash
docker run \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ...
```

This allows the user to run Docker commands without sudo.

Example:

```bash
docker ps
docker compose up -d
```

If no Docker socket is present, this step is skipped.

# User Initialization Script

The container can execute a user-provided startup script.

Location:

```text
~/.config/homebox/init.sh
```

Example:

```bash
mkdir -p ~/.config/homebox
```

```bash
cat > ~/.config/homebox/init.sh <<'EOF'
#!/bin/bash

echo "Initializing user environment"

mkdir -p ~/workspace
git config --global init.defaultBranch main
EOF
```

```bash
chmod +x ~/.config/homebox/init.sh
```

During startup:

```text
/home/<user>/.config/homebox/init.sh
```

is executed automatically if present.

This can be used to:

* Configure dotfiles.
* Clone repositories.
* Initialize development environments.
* Create directories.
* Install user-specific configuration.

# Example Docker Compose

```yaml
services:
  homebox:
    image: my-image

    ports:
      - "2222:22"

    environment:
      HOMEBOX_USER_LOGIN: john
      HOMEBOX_USER_UID: 1000
      HOMEBOX_USER_GID: 1000
      HOMEBOX_USER_SUDO: "true"
      HOMEBOX_USER_PUBKEYS: >-
        https://github.com/john.keys

    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./home:/home/john
```

# Startup Sequence

The initialization process executes in the following order:

```text
10-sshd-config.sh
 ├─ Validate sshd configuration
 └─ Generate SSH host keys

30-dynamic-user.sh
 ├─ Create/update user
 ├─ Install authorized_keys
 ├─ Configure Docker permissions
 ├─ Configure sudo (optional)
 └─ Run ~/.config/homebox/init.sh

Supervisor
 └─ Start sshd
```

# Security Notes

* No support for account password
* SSH password authentication should be disabled whenever possible.
* Use public-key authentication instead of passwords.
* `HOMEBOX_USER_SUDO=true` grants unrestricted passwordless root access.
* Access to `/var/run/docker.sock` effectively grants root-equivalent access to the host Docker daemon.
* Public key URLs are fetched during startup; only use trusted sources.

