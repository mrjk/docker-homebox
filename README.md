# Homebox - Your personal development environment in a docker

This project aims to provide a ssh accessible container for developper with many troubleshooting and useful utils. It support permanent home.

Source project on github: [mrjk/docker-homebox](https://github.com/mrjk/docker-homebox/)

## Quickstart

Cold start with shell:
```
docker compose run --rm -ti -u root --entrypoint /bin/bash  user_debian
docker compose run --rm -ti -u ${app_username:-user} user_debian /bin/bash
```

To enter into current session:
```
docker compose exec -ti -u root user_debian /bin/bash
docker compose exec -ti -u ${app_username:-user} user_debian /bin/bash
```

## Features

- Expose host ssh-agent socket
- Provide a default ssh-server
- provide common tools such as git, rsync, vim and more
- Customizable user build/init script
- Deployable as docker compose
- docker client with docker compose

Todo:
- Support rootless container
- Cleanup project


## Usage

This image is designed to be used as regular user. You are supposed to access it via SSH port. 
While this image provides a sudo access, to make persistant installation, you need to install it
in your home. Homebrew and mise are provided for conveniance.


## Custom build

This image comes with a generic user, you may want to customize the image.

### Manual overrides

Export docker environment config:
```bash
export COMPOSE_ENV_FILES=.env,.env.overrides
```

Then create a new .env.overrides file, that overrides `.env` settings:
```bash
# Docker settings
# ==================
COMPOSE_FILE=docker-compose.yml:compose.ssh-socket.yml:compose.persistant.yml:compose.docker.yml
COMPOSE_PROFILES=default
COMPOSE_PROGRESS=plain

# User Configuration
# ==================
app_username=mrjk
app_user_id=3000
app_group_id=3000

# SSH Authorized Keys (comma-separated or newline-separated)
app_ssh_authorized_keys=ssh-ed25519 AAAAC3NzaC1lZD.... mrjk
```

### Override with direnv

Create a simple `.envrc` for direnv, and run `direnv allow`:
```bash
export COMPOSE_ENV_FILES=.env,.env.overrides
```
Docker will now use overrides by default.



