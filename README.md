# Personal image working image

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



