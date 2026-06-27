#!/usr/bin/env bash

set -euo pipefail

readonly SITE_DIR="${SITE_DIR:-site}"
readonly PAGES_BRANCH="${PAGES_BRANCH:-doc-pages}"
readonly WORKTREE_DIR="${WORKTREE_DIR:-.tmp-gh-pages}"

main() {
    check_requirements
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
        "refs/heads/${PAGES_BRANCH}"
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
