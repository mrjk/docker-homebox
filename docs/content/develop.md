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

Build docker image:
```
task build
```


## Build documentation

To locally run documentation:
```
cd docs/
task setup serve
```
Then you can reach documentation on [http://localhost:8000/]()

## Release and publish

### Environment vars

Configure environment vars in `.envrc` or directly in your shell:
```
export DOCKERHUB_REPOSITORY=docker-homebox
export DOCKERHUB_NAMESPACE=mrjk78
export DOCKERHUB_USERNAME=mrjk78
export DOCKERHUB_TOKEN=...
export GITHUB_TOKEN=...
```

### Pipelines


#### Dev

Push the dev image to registries: 
```
# Push on develop channel
task push 

# Push on develop channel with pre-release
task release
task push 
```

#### Stable
Stable deployment, only on main branch:
```
task release
task push-stable
```

