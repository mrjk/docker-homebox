---
icon: lucide/bug
---


# Develop

Requirements:
* mise
* direnv
* running docker and docker compose

## Quickstart

Clone project:
```
git clone git@github.com:mrjk/docker-homebox.git
cd docker-homebox
```

Allow mise to trust this project:
```
mise trust
```

### Local build

Build docker image:
```
task build
```

### Documentation build

To locally run documentation:
```
task docs:serve
```
Then you can reach documentation on [http://localhost:8000/]()


## Releasing and publishing

The releasing and publishing process is handled with Task. Pipeline is quite simple. Development branches only push docker images, stable deployment update documentation and dockerhub readme.

### Dev

Push the dev image to registries: 
```
# Push on develop channel, without release
task push 

# Push on develop channel with pre-release
task release
task push 
```

### Stable

Configure environment vars in `.envrc` or directly in your shell:
```
export DOCKERHUB_REPOSITORY=docker-homebox
export DOCKERHUB_NAMESPACE=mrjk78
export DOCKERHUB_USERNAME=mrjk78
export DOCKERHUB_TOKEN=...
export GITHUB_TOKEN=...
```

Stable deployment, only on main branch:
```
task release
task push-stable
```

