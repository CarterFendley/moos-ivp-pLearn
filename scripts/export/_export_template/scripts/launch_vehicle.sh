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

# Point container to shoreside on host machine
DOCKER_GATEWAY="host.docker.internal"

SHORE_IP="$(ping -c 1 -t 1 $DOCKER_GATEWAY | head -1 | cut -d ' ' -f 3 | tr -d '()\:')"
if [ -z "$SHORE_IP" ]; then
    echo "Unable to resolve docker gateway '$DOCKER_GATEWAY' to IP!"
    exit 1
else
    echo "Docker gateway resolved to $SHORE_IP"
fi

# Parse important arguments to pass to launch script
TIME_WARP=1
VEHICLE_FLAG="-f"
TEAM_FLAG="-r"

SIM="SIM" # Set sim too cause normal sim flag will over ride the shore_ip

export SHORE_IP # Export for the ./launch_m200_test.sh
export SIM

for ARGI; do
    # Get time warp
    if [ "${ARGI//[^0-9]/}" = "$ARGI" -a "$TIME_WARP" = 1 ]; then
        TIME_WARP=$ARGI
    fi
    case "$ARGI" in
        "-e"|"-f"|"-g"|"-H"|"-i"|"-J")
            VEHICLE_FLAG="$ARGI";;
        "--evan"|"--felix"|"--gus"|"--hal"|"--ida"|"--jing")
            VEHICLE_FLAG="$ARGI";;
        "--red"|"-r"|"--blue"|"-b")
            TEAM_FLAG="$ARGI";;
    esac
done

# ----------------------------------------
# Part 2: Run Reinforce

# This outputs information for the behavior to use
python "$REINFORCE_PATH" test

# ----------------------------------------
# Part 2: Run m200 launch script
PREVIOUS_WD="$(pwd)"
cd "$M200_PATH"

./launch_m200_test.sh $VEHICLE_FLAG $TEAM_FLAG $TIME_WARP >& /dev/null &

sleep 3

uMAC targ_*.moos # This should be safe so long as there is only one vehicle launched in the container

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