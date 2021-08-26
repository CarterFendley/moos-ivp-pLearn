#!/usr/bin/env bash

# Cd to dir to make paths uniform
DIRNAME="$(dirname $0)"
cd $DIRNAME

# Test OS type for use letter
OS_TYPE="UNSET"

if [ "$(uname)" == "Linux" ]; then
    OS_TYPE="linux"
elif [ "$(uname)" == "Darwin" ]; then
    OS_TYPE="osx"
else
    printf "ERROR: Unable to determine OS type.\n"
    exit 1
fi

# Handle arguments
if [[ -z "$1" ]] || [[ "$1" = "help" ]] || [[ "$1" = "--help" ]] || [[ "$1" = "-h" ]]; then
    printf "Usage: %s <COMMAND>\n" $0
    printf "Commands:\n"
    printf "\t build   - Build docker image and tag as \"plearn\"\n"
    printf "\t run     - Run a docker container from image tagged as \"plearn\"\n"
    printf "\t stop    - Stops a docker container from image tagged as \"plearn\"\n"
    printf "\t rm      - Removes a docker container from image tagged as \"plearn\"\n"
    printf "\t connect - Connect to the docker containertagged ad \"plearn\"\n"
    exit 0;
elif [[ "$1" == "build" ]]; then
    printf "Building plearn container...\n"
    docker build -t plearn:1.0 .
elif [[ "$1" == "run" ]]; then
    printf "Enabling xhost server...\n"
    xhost +
    printf "Starting docker container...\n"
    printf "\n==========================================\n"
    printf "= To exit and stop: run command \"exit\"   =\n"
    printf "= To detach: CTRL+p CTRL+q               =\n"
    printf "==========================================\n\n"

    if [[ "$OS_TYPE" == "osx" ]]; then
        docker run --env="DISPLAY=host.docker.internal:0" \
            --volume="/tmp/.X11-unix:/tmp/.X11-unix" \
            --mount type=bind,source="$(pwd)"/pLearn,target=/home/moos/moos-ivp-pLearn/pLearn \
            --mount type=bind,source="$(pwd)"/scripts,target=/home/moos/moos-ivp-pLearn/scripts \
            --name plearn -it plearn:1.0 bash 
    elif [[ "$OS_TYPE" == "linux" ]]; then
        docker run --env="DISPLAY" \
            --volume="/tmp/.X11-unix:/tmp/.X11-unix" \
            --mount type=bind,source="$(pwd)"/pLearn,target=/home/moos/moos-ivp-pLearn/pLearn \
            --name plearn -it plearn:1.0 bash 
    fi

    printf "WARNING: Docker container will run in background unless stopped\n"
elif [[ "$1" == "connect" ]]; then
    printf "Conecting to docker container...\n"
    printf "\n==========================================\n"
    printf "= To detach: CTRL+p CTRL+q               =\n"
    printf "==========================================\n\n"
    docker exec -it plearn bash
elif [[ "$1" == "stop" ]]; then
    printf "Stopping docker container...\n"
    docker stop plearn
elif [[ "$1" == "rm" ]]; then
    printf "Deleting docker container...\n"
    docker rm plearn
else
    printf "Error: Unrecognized argument\n"
    exit;
fi