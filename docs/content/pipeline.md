# Project pipelines

## Universal CI

No workspace, namespaces or users should be hardcoded into the repo. Everything should be injected
as environment variables. There must be a 1 to 1 CI functionality parity:
* Environment dependencies are handled with mise
  * See: jdx/mise-action@v3
 with https://mise.jdx.dev/continuous-integration.html
* CI tasks is handled by Taskfile.dev
  * Only tasks starting with `ci-` are allowed to be called by CI system
* Environment vars and secrets:
  * Local: Handled by environment vars, with direnv
  * Remote: Handled by remote system, env vars and secrets are injected in the solution

## Releasing

Release mechanism is depends on latest commit messages:

| Commit type               | Release                 |
| ------------------------- | ----------------------- |
| `*:`                      | None  (`1.0.0 → 1.0.0`) |
| `fix:`                    | Patch (`1.0.0 → 1.0.1`) |
| `perf:`                   | Patch (`1.0.0 → 1.0.1`) |
| `feat:`                   | Minor (`1.0.0 → 1.1.0`) |
| `*!:`                     | Major (`1.0.0 → 2.0.0`) |
| `BREAKING CHANGE:` footer | Major (`1.0.0 → 2.0.0`) |

All allowed prefixes are:

| Syntax                         | Release impact | Notes                                      |
| ------------------------------ | -------------- | ------------------------------------------ |
| `feat!:`                       | Major          | Breaking feature                           |
| `fix!:`                        | Major          | Breaking bug fix                           |
| `BREAKING CHANGE:` (footer)    | Major          | Explicit breaking change declaration       |
| `feat:`                        | Minor          | New feature                                |
| `fix:`                         | Patch          | Bug fix                                    |
| `perf:`                        | Patch          | Performance improvement                    |
| `docs:`                        | None           | Documentation only                         |
| `chore:`                       | None           | Maintenance tasks                          |
| `ci:`                          | None           | CI/CD changes                              |
| `build:`                       | None           | Build system / Docker / packaging          |
| `test:`                        | None           | Test additions or changes                  |
| `refactor:`                    | None           | Code restructuring without behavior change |
| `style:`                       | None           | Formatting / linting only                  |


## Workflow

Rules:
* Anything commited on `main` will trigger a new semantic release.
  * Increment release
  * Build docker image
  * Build and push documentation on github pages
  * Push image on registry
  * Update dockerhub readme
  * Update dev branch to include new release
* Anything commited on `dev` will trigger a unstable release
  * Build docker image
  * Push image on registry
* Anything commited on other branches will do nothing


On github UI, you can run two jobs on any branches:
* CI: Run CI and build, don't publish
* Publish: Run CI and publish artifacts

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


