# Homebox - Your personal development environment in a docker

This project aims to provide a ssh accessible container for developper with many troubleshooting and useful utils. It support permanent home.

Source project on github: [mrjk/docker-homebox](https://github.com/mrjk/docker-homebox/)

## Quickstart

Cold start with shell:
```
. .env
docker compose run --rm -ti -u root --entrypoint /bin/bash  user_debian
docker compose run --rm -ti -u $app_username user_debian /bin/bash
```

To enter into current session:
```
. .env
docker compose exec -ti -u root user_debian /bin/bash
docker compose exec -ti -u $app_username user_debian /bin/bash
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


