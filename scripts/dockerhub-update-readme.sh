#!/usr/bin/env bash

set -euo pipefail

readonly README_FILE="${README_FILE:-README.md}"
readonly DOCKERHUB_NAMESPACE="${DOCKERHUB_NAMESPACE:?missing DOCKERHUB_NAMESPACE}"
readonly DOCKERHUB_REPOSITORY="${DOCKERHUB_REPOSITORY:?missing DOCKERHUB_REPOSITORY}"
readonly DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:?missing DOCKERHUB_USERNAME}"
readonly DOCKERHUB_TOKEN="${DOCKERHUB_TOKEN:?missing DOCKERHUB_TOKEN}"

main() {
    check_requirements
    token="$(get_access_token)"
    update_repository "${token}"
}

check_requirements() {
    command -v curl >/dev/null
    command -v jq >/dev/null

    [ -f "${README_FILE}" ] || {
        echo "README not found: ${README_FILE}" >&2
        exit 1
    }
}

get_access_token() {
    curl \
        --silent \
        --fail \
        --show-error \
        -H "Content-Type: application/json" \
        -X POST \
        https://hub.docker.com/v2/users/login/ \
        -d "$(login_payload)" \
    | jq -r '.token'
}

login_payload() {
    jq -nc \
        --arg username "${DOCKERHUB_USERNAME}" \
        --arg password "${DOCKERHUB_TOKEN}" \
        '{
            username: $username,
            password: $password
        }'
}


update_repository() {
    local token="$1"

    local response

    response="$(
        curl \
            --silent \
            --fail \
            --show-error \
            -X PATCH \
            -H "Authorization: JWT ${token}" \
            -H "Content-Type: application/json" \
            "https://hub.docker.com/v2/repositories/${DOCKERHUB_NAMESPACE}/${DOCKERHUB_REPOSITORY}/" \
            -d "$(repository_payload)"
    )"

    print_success
}

print_success() {
    local url

    url="https://hub.docker.com/r/${DOCKERHUB_NAMESPACE}/${DOCKERHUB_REPOSITORY}"

    echo
    echo "Docker Hub README updated successfully"
    echo "Repository: ${DOCKERHUB_NAMESPACE}/${DOCKERHUB_REPOSITORY}"
    echo "URL: ${url}"
}

repository_payload() {
    jq -Rs \
        '{ full_description: . }' \
        < "${README_FILE}"
}

main "$@"
