#!/usr/bin/env bash

BUILDTAGS=""
REGISTRIES="docker.io ghcr.io"
REPOSITORY="authelia/baseimage"
TAGS=""

if [[ "${BUILDKITE_BRANCH}" =~ ^renovate/ ]]; then
  TAGS="renovate"
elif [[ "${BUILDKITE_BRANCH}" != "master" ]] && [[ ! "${BUILDKITE_BRANCH}" =~ .*:.* ]]; then
  TAGS="${BUILDKITE_BRANCH}"
elif [[ "${BUILDKITE_BRANCH}" != "master" ]] && [[ "${BUILDKITE_BRANCH}" =~ .*:.* ]]; then
  TAGS="PR${BUILDKITE_PULL_REQUEST}"
elif [[ "${BUILDKITE_BRANCH}" == "master" ]] && [[ "${BUILDKITE_PULL_REQUEST}" == "false" ]]; then
  TAGS="latest"
fi

[[ ${BUILDKITE_BUILD_NUMBER} != "" ]] && TAGS+=" BK${BUILDKITE_BUILD_NUMBER}"
[[ ${AUTHELIA_RELEASE} != "" ]] && TAGS+=" ${AUTHELIA_RELEASE}"

for REGISTRY in ${REGISTRIES}; do for TAG in ${TAGS}; do BUILDTAGS+="-t ${REGISTRY}/${REPOSITORY//image}:${TAG} "; done; done

cat << EOF
steps:
  - label: ":docker: Build and Deploy"
    command: "docker build ${BUILDTAGS::-1} --label org.opencontainers.image.source=https://github.com/${REPOSITORY} --platform linux/amd64,linux/arm/v7,linux/arm64 --builder buildx --pull --push ."
    concurrency: 1
    concurrency_group: "baseimage-deployments"
    agents:
      upload: "fast"

  - wait

  - label: ":docker: Update README.md"
    command: "curl \"https://ci.nerv.com.au/readmesync/update?github_repo=${REPOSITORY}&dockerhub_repo=${REPOSITORY//image}\""
    agents:
      upload: "fast"
    if: build.branch == "master"
EOF