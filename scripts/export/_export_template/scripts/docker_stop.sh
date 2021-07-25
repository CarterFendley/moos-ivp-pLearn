#!/usr/bin/env bash

STUB_NAME="../pLearn_docker_stub"

# Fail if subcommands fail
set -e

# Reset to current working directory on exit
PREVIOUS_WD="$(pwd)"
trap 'cd $PREVIOUS_WD' EXIT

# CD to this scripts' dir 
cd "$(dirname $0)"

if [[ ! -f "$STUB_NAME" ]]; then
    echo "ERROR: Stub not found"
    exit 1
fi 

STUB_ID="$(<$STUB_NAME)"

printf "Stopping docker container $STUB_ID...\n"
docker stop "$STUB_ID"
printf "Done!\n"