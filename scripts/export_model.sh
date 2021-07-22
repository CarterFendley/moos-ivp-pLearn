#!/usr/bin/env bash
# Author: Carter Fendley 2021
# Attributions: Thanks to Conlan Ceaser (HeroCC) & Misha Novitzky for blazing the trail of Docker + MOOS-IvP

HELP=""

MYDIR="$(dirname "$(realpath "$0")")"
SIM_DIR="$MYDIR/../pLearn/simulation_engine"
LEARNING_CODE_DIR="$MYDIR/../pLearn/learning_code"
BEHAVIOR_DIR="$MYDIR/../src"

MODEL_PATH="$(pwd)/${1}"
EXPORT_TO_DIR="exported_model"

# Tests
printf "Running tests on model path... "

if [[ -z "$1" ]]; then
  HELP="yes"
  printf "ERROR!\n\n"
  echo "ERROR: <MODEL_PATH> is a required parameter"
  echo ""
elif [[ ! -d "$MODEL_PATH" ]]; then
  HELP="yes"
  printf "ERROR!\n\n"
  echo "ERROR: <MODEL_PATH> must be a directory"
  echo ""
elif [[ ! -f "$MODEL_PATH/../environment.py" ]]; then
  HELP="yes"
  printf "ERROR!\n\n"
  echo "ERROR: <MODEL_PATH> must have \"enviroment.py\" file in parent directory"
  echo ""
else
  printf "Done!\n"
  echo "$MODEL_PATH"
fi

printf "Running tests on export directory... "

if [[ -d "$EXPORT_TO_DIR" ]]; then
  HELP="yes"
  printf "ERROR!\n\n"
  echo "ERROR: $EXPORT_TO_DIR directory already exists. Please (re)move before exporting another model."
  echo ""
elif [[ -f "$EXPORT_TO_DIR" ]]; then
  HELP="yes"
  printf "ERROR!\n\n"
  echo "ERROR: $EXPORT_TO_DIR is a file. Please (re)move before exporting model."
  echo ""
else
  printf "Done!\n"
fi 

if [[ -n $HELP ]]; then
  echo "Usage: $0 <MODEL_PATH>"
  exit 0
fi

# Prepare to copy files by making the script
set -e # Exit script is any of the command fails
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "ERROR: \"${last_command}\" command filed with exit code $?."' EXIT

# Copy model files
printf "\nCopying model files... "
mkdir "$EXPORT_TO_DIR"
cp "$MODEL_PATH/../environment.py" "$EXPORT_TO_DIR/environment.py"
cp "$MODEL_PATH/../environment.py" "$EXPORT_TO_DIR/Constants.py"

cp -r "$MODEL_PATH" "$EXPORT_TO_DIR/model"
printf "Done!\n"

# Copy pLearn python files
printf "Copying pLearn python files... "
cp "$LEARNING_CODE_DIR/reinforce.py" "$EXPORT_TO_DIR/reinforce.py"
cp "$LEARNING_CODE_DIR/DeepLearn.py" "$EXPORT_TO_DIR/DeepLearn.py"

printf "Done!\n"

# Copy pLearn behavior library
printf "Copying pLearn behavior files... "
cp -r "$BEHAVIOR_DIR" "$EXPORT_TO_DIR"
cp "$MYDIR/../build.sh" "$EXPORT_TO_DIR"
cp "$MYDIR/../clean.sh" "$EXPORT_TO_DIR"
cp "$MYDIR/../CMakeLists.txt" "$EXPORT_TO_DIR"
printf "Done!\n"


# Copy misson files
printf "Copying mission files... "
mkdir -p "$EXPORT_TO_DIR/mission/m200"
cp "$SIM_DIR/m200/launch_m200_test.sh" "$EXPORT_TO_DIR/mission/m200"
cp "$SIM_DIR/m200/clean.sh" "$EXPORT_TO_DIR/mission/m200"
cp "$SIM_DIR/m200/plug_"*".moos" "$EXPORT_TO_DIR/mission/m200"
cp "$SIM_DIR/m200/meta_m200.moos" "$EXPORT_TO_DIR/mission/m200"
cp "$SIM_DIR/m200/meta_m200.bhv" "$EXPORT_TO_DIR/mission/m200"

cp "$SIM_DIR/plug_"*".moos" "$EXPORT_TO_DIR/mission"
printf "Done!\n"

# Unset the traps
set +e
trap - EXIT
trap - DEBUG

echo ""
echo "There should now be a exported vehicle in: $(pwd)/${EXPORT_TO_DIR}"

echo ""
echo "============================"
echo "=        WARNING           ="
echo "============================"
echo "This scripts tests are not exhaustive! If pLearn is changed"
echo "significantly this script will need updating. See assumptions"
echo "in comments at the end of this script."

# Assumptions
# 1) The given path holds .h5 file(s) which hold the model
# 2) The enviroment.py file in parent directory will corrispond to the model
# 3) The current version of reinforce.py will know how to interpert the enviroment.py file
# 4) The "self.test_address" from Constants.py is used to tell reinforce.py which configure for execution
#   4.a) The current version of DeepLearn.py will properly out put a table.csv file that is compatable with current versions of BHV_Input and call_keras.py
# 5) The current "run.sh" script will properly excute the model in the simulation enviroment
# 6) The Aquaticus enviroment will not change enough to make old models obsolete (risky)
# 7) There are always more assumptions... this should get you started if the script breaks