# Github Action

## Workflow

Rules:
* Anything commited on `main` will trigger a new semantic release.
  * Build and increment release
  * Publish stable
  * Need `git rebase` after each commit on `main`
* Anything commited on `dev` will trigger a unstable release
  * Build
  * Publish develop
* Anything commited on other branches will do nothing

Rebuild is disabled on some files, such as `*.md`

On github UI, you can run two jobs:
* CI: Run CI and build
* Publish: Run CI and publish version to dockerhub

## Setup

Dockerhub config:
* Go to `Account/Settings`
* Go to `Personal Access Tokens`
* Create a new access token
  * Description: `gh-action-<PROJECT_NAME>`
  * Scopes: Read, Write, Delete
  * Save token for later use in Github

Github config:
* Go to project `Settings`
* Go to `Secrets and variables/Actions`
* Create `New repository secret`
  * Name: `DOCKERHUB_TOKEN`
  * Secret: Get from dockerhub
* Create `New repository variable`
  * Name: `DOCKERHUB_USERNAME`
  * Value: Your dockerhub user

Then you should be able to run github actions on dockerhub.

In `job_dockerhub_publish.yml`, you can adapt where the docker file is.

