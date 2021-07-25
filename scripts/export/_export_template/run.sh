#!/usr/bin/env bash

# ----------------------------------------
# Part 1: Setup

# Fail if subcommands fail
set -e

# Reset to current working directory on exit
PREVIOUS_WD="$(pwd)"
cd "$(dirname $0)"

# Create tear_down function for shutdown / errors
function tear_down() {
  set +e

  if [[ ! -z "$IMAGE_ID" ]]; then
    echo "Stopping container $IMAGE_ID..."
    docker stop "$IMAGE_ID"
    echo "Removing container $IMAGE_ID..."
    docker rm "$IMAGE_ID"
  fi

  cd $PREVIOUS_WD
}
trap tear_down EXIT

STUB_NAME="pLearn_docker_stub"

# ----------------------------------------
# Part 2: Get / Build docker image

# If no docker image stub, build image
if [[ ! -f "$STUB_NAME" || "$1" == "--build" ]]; then
  ./docker_build.sh --force
fi

IMAGE_ID="$(<$STUB_NAME)"

# ----------------------------------------
# Part 3: Run docker image

# Open felix's pShare port 9306
#docker run -p 9306:9306 --name "$IMAGE_ID" -it "$IMAGE_ID" bash
docker run -p 9306:9306 --name "$IMAGE_ID" \
  --add-host host.docker.internal:host-gateway \
  -it "$IMAGE_ID" /home/moos/exported_pLearn/scripts/launch_vehicle.sh
