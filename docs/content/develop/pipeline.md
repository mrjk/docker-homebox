---
icon: lucide/workflow
---

# Pipelines

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
    1. Increment release
    * Build docker image
    * Build and push documentation on github pages
    * Push image on registry
    * Update dockerhub readme
    * Update dev branch to include new release
* Anything commited on `dev` will trigger a unstable release
    1. Build docker image
    * Push image on registry
* Anything commited on other branches will do nothing


On github UI, you can run two jobs on any branches:

* CI: Run CI and build, don't publish
* Publish: Run CI and publish artifacts

## Setup

Docker Hub auth for the Release workflow uses the GitHub Environment `release-publish`.
`DOCKERHUB_TOKEN` is injected only on push / Hub README steps, not on docs build.

### 1. Docker Hub access token

1. Open [Docker Hub](https://hub.docker.com/) -> Account Settings -> Personal access tokens
2. Create a token
   * Description: `gh-action-<PROJECT_NAME>`
   * Access permissions: Read, Write, Delete
3. Copy the token (shown once)

### 2. GitHub Environment

1. Open the GitHub repo -> Settings -> Environments
2. Create environment named exactly: `release-publish`
3. Optional hardening:
   * Deployment branches: only `main` (and `dev` if you publish from there)
   * Required reviewers: if you want a human gate before Hub push

### 3. Environment secret

Still on Environment `release-publish` -> Environment secrets:

| Name | Value |
| ---- | ----- |
| `DOCKERHUB_TOKEN` | Docker Hub access token from step 1 |

Do not put `DOCKERHUB_TOKEN` in repository Actions secrets (avoid duplicate / accidental job-wide use).

### 4. Environment variables

Still on Environment `release-publish` -> Environment variables:

| Name | Value | Required |
| ---- | ----- | -------- |
| `DOCKERHUB_USERNAME` | Docker Hub username that owns the token | Yes |
| `DOCKERHUB_NAMESPACE` | Hub namespace / org for image path (`namespace/repo`) | No (defaults to username) |

`DOCKERHUB_REPOSITORY` is set by the workflow to the GitHub repo name.

### 5. Verify

1. Ensure the Hub repository `DOCKERHUB_NAMESPACE/<github-repo-name>` exists (or can be created by that user)
2. Run Actions -> Release -> Run workflow on `main` or `dev`
3. Confirm image push and (on `main`) Hub README update

CI workflow does not receive Docker Hub credentials.


