#!/usr/bin/env bash
set -u

REPOSITORY="authelia/baseimage"
TAG="latest"

cat << EOF
steps:
  - label: ":docker: Build and Deploy"
    command: "docker build --tag ${REPOSITORY//image}:${TAG} --platform linux/amd64,linux/arm/v7,linux/arm64 --builder buildx --pull --push ."
    concurrency: 1
    concurrency_group: "baseimage-deployments"
    agents:
      upload: "fast"

  - wait

  - label: ":docker: Update README.md"
    command: "curl \"https://ci.nerv.com.au/readmesync/update?github_repo=${REPOSITORY}&dockerhub_repo=${REPOSITORY//image}\""
    agents:
      upload: "fast"
EOF