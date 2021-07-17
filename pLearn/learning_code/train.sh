#!/bin/bash

VERBOSE=""

#-----------------------------------------------------
#       Script to Run Simulation and Extract Data
#-----------------------------------------------------    
echo "[TRAINER] Launching simulation..."
cd ../simulation_engine
./clean.sh

./launch_reinforce.sh  bett4 &
last_pid=$!
echo "[TRAINER] Waiting to allow time for simulation nodes to start..."   
sleep 15 

echo "[TRAINER] Deploying simulated robots..."
cd shoreside
if [[ -z $VERBOSE ]]; then
    uPokeDB  targ_shoreside.moos DEPLOY_ALL=true MOOS_MANUAL_OVERRIDE_ALL=false RETURN_ALL=false STATION_KEEP_ALL=false >& /dev/null 
else
    uPokeDB  targ_shoreside.moos DEPLOY_ALL=true MOOS_MANUAL_OVERRIDE_ALL=false RETURN_ALL=false STATION_KEEP_ALL=false
fi
cd ..
#run simulation for some number of iterations or until tagged or flag captured
count=0
while [[ $count -lt 20 ]] ; do #20
    sleep 1
    count=$((count+1))
done

#kill the simulation
echo "[TRAINER] Killing simulation via pid..."
kill -INT $last_pid > /dev/null
sleep 3

#kill hte moos application
echo "[TRAINER] Killing the MOOS..."
ktm
sleep 5

ktm
sleep 5

ktm
sleep 5

cd ../learning_code
args=("$@")
#make test folder and store data
echo "[TRAINER] Making \"results\" folder for simulation data..."
cd results
mkdir simulation_${args[0]}
cd ..

cd ../simulation_engine
#process log data to extract states, actions, and end states (Felix is the robot exhibiting learning behavior)
echo "[TRAINER] Extracting data from felix's alog via aloggrep..."
cd m200
cd LOG_FELIX_*
aloggrep L*.alog INP_STAT felix.alog
cd ../../..
mv simulation_engine/m200/LOG_FELIX_*/felix.alog learning_code/results/simulation_${args[0]}/simulation.alog


cd simulation_engine
#clean the test folder to remove old logs
echo "[TRAINER] Clearing simulation log files..."
./clean.sh
sleep 2

cd ../learning_code
