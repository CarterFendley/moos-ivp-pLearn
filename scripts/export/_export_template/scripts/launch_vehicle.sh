#!/usr/bin/env bash

# ----------------------------------------
# Part 1: Setup

set -e # Exit script is any of the command fails
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "ERROR: \"${last_command}\" command filed with exit code $?."' EXIT

HELP=""

# Helper path to find absolute path
actualpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

MYDIR="$(dirname "$(actualpath "$0")")"
REINFORCE_PATH="$MYDIR/../reinforce.py"
M200_PATH="$MYDIR/../mission/m200/"

# ----------------------------------------
# Part 2: Run Reinforce

# This outputs information for the behavior to use
python "$REINFORCE_PATH" test

# ----------------------------------------
# Part 2: Run m200 launch script
PREVIOUS_WD="$(pwd)"
cd "$M200_PATH"

./launch_m200_test.sh -f -r -s >& /dev/null &

sleep 3

uMAC targ_felix.moos

cd "$PREVIOUS_WD"

# ----------------------------------------
# Part X: Tear down

# Unset the traps
set +e
trap - EXIT
trap - DEBUG

echo "Killing vehicle..."
kill -- -$$
sleep 3
echo "All processes killed"