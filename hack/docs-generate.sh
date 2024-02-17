#!/usr/bin/env bash

set -ex

HELM_CHART="blink"
LOCAL_CONTAINER="localhost/readme-gen"

# Check for Podman
if command -v podman &> /dev/null; then
  echo "🟢 Podman found, switching security context"
  export CONTAINER_PLATFORM="podman"
  export CONTAINER_ARGS="--security-opt label=disable"
else
  echo "🔴 Podman not found, defaulting to Docker"
  export CONTAINER_PLATFORM="docker"
fi

# Clone and build:
if [ ! -d "readme-generator-for-helm" ]; then
  git clone https://github.com/bitnami-labs/readme-generator-for-helm
fi

"${CONTAINER_PLATFORM}" build \
  -t "${LOCAL_CONTAINER}" \
  readme-generator-for-helm/

# Run the tool and mount the current project directory.
"${CONTAINER_PLATFORM}" run \
  --rm -it \
  ${CONTAINER_ARGS} \
  -v "${PWD}:/mnt" \
  -w /mnt \
  ${LOCAL_CONTAINER} \
  readme-generator \
  -v "/mnt/${HELM_CHART}/values.yaml" \
  -r "/mnt/${HELM_CHART}/README.md"
