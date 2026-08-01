#!/usr/bin/env bash

set -euo pipefail

readonly SITE_DIR="${SITE_DIR:-site}"
readonly PAGES_BRANCH="${PAGES_BRANCH:-doc-pages}"
readonly WORKTREE_DIR="${WORKTREE_DIR:-.tmp-gh-pages}"

main() {
    check_requirements
    configure_git_identity
    prepare_worktree
    sync_site
    commit_changes
    push_changes
    cleanup
}

check_requirements() {
    command -v git >/dev/null 2>&1 || {
        echo "git not found" >&2
        exit 1
    }

    [ -d "${SITE_DIR}" ] || {
        echo "site directory not found: ${SITE_DIR}" >&2
        exit 1
    }
}

configure_git_identity() {
    local name="${GIT_AUTHOR_NAME:-${GIT_COMMITTER_NAME:-${GITHUB_ACTOR:-}}}"
    local email="${GIT_AUTHOR_EMAIL:-${GIT_COMMITTER_EMAIL:-}}"

    if [ -z "${email}" ] && [ -n "${GITHUB_ACTOR:-}" ]; then
        email="${GITHUB_ACTOR}@users.noreply.github.com"
    fi

    if [ -z "${name}" ] || [ -z "${email}" ]; then
        echo "git identity required: set GIT_AUTHOR_NAME and GIT_AUTHOR_EMAIL" >&2
        exit 1
    fi

    export GIT_AUTHOR_NAME="${name}"
    export GIT_AUTHOR_EMAIL="${email}"
    export GIT_COMMITTER_NAME="${GIT_COMMITTER_NAME:-${name}}"
    export GIT_COMMITTER_EMAIL="${GIT_COMMITTER_EMAIL:-${email}}"
}

prepare_worktree() {
    rm -rf "${WORKTREE_DIR}"

    if branch_exists; then
        git worktree add "${WORKTREE_DIR}" "${PAGES_BRANCH}"
        return
    fi

    create_orphan_branch
}

branch_exists() {
    git show-ref \
        --verify \
        --quiet \
        "refs/heads/${PAGES_BRANCH}" || \
    git show-ref --verify --quiet "refs/remotes/origin/${PAGES_BRANCH}"
}

create_orphan_branch() {
    git worktree add --detach "${WORKTREE_DIR}"

    (
        cd "${WORKTREE_DIR}"

        git checkout --orphan "${PAGES_BRANCH}"

        find . \
            -mindepth 1 \
            -maxdepth 1 \
            ! -name .git \
            -exec rm -rf {} +
    )
}

sync_site() {
    (
        cd "${WORKTREE_DIR}"

        git pull

        find . \
            -mindepth 1 \
            -maxdepth 1 \
            ! -name .git \
            -exec rm -rf {} +

        cp -a "../${SITE_DIR}/." .
    )
}

commit_changes() {
    (
        cd "${WORKTREE_DIR}"

        git add -A

        if git diff --cached --quiet; then
            echo "No changes to deploy"
            return
        fi

        git commit \
            -m "Deploy $(git -C .. rev-parse --short HEAD)"
    )
}

push_changes() {
    (
        cd "${WORKTREE_DIR}"

        git push origin "${PAGES_BRANCH}"
    )
}

cleanup() {
    git worktree remove "${WORKTREE_DIR}" --force 2>/dev/null || true
}

trap cleanup EXIT

main "$@"
