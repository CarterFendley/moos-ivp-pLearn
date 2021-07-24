#!/usr/bin/env bash

STUB_NAME="pLearn_docker_stub"

# Fail if subcommands fail
set -e

# Reset to current working directory on exit
PREVIOUS_WD="$(pwd)"
trap 'cd $PREVIOUS_WD' EXIT

# CD to this scripts' dir 
cd "$(dirname $0)"

# Check if for stub of prebuilt container
if [[ -f "$STUB_NAME" ]]; then
  if [[ "$1" != "-f" && "$1" != "--force" ]]; then
    echo "ERROR: Stub file indicates that docker image had been build"
    echo "Run $0 --force if you wish to rebuild"
    exit 1
  fi
  
  # Get stub id
  STUB_ID="$(<$STUB_NAME)"

  # Remove containers
  set +e # Allow next commands to fail (containers may or may not exist)
  echo "Shutting down conatiners..."
  docker stop "$STUB_ID"
  echo "Removing containers..."
  docker rm "$STUB_ID"
  set -e

  # Remove image
  echo "Removing docker image $STUB_ID found in stub..."
  docker image rm "$STUB_ID"
fi

# Build image and grab ID
echo "Building docker container (this may take a while)..."
IMAGE_ID="$(docker build . 2>/dev/null | awk '/Successfully built/{print $NF}')"

# Assert scucess
if [[ -z $IMAGE_ID ]]; then
  printf "ERROR: Failed to build docker container."
  exit 1
fi

# Make a stub with the IMAGE_ID
echo "$IMAGE_ID" > "$STUB_NAME"

# Directory will be restored by trap