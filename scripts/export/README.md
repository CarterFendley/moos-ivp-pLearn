# Export script

This script is still **very new** besides following the instructions, it might be helpful to look at the warnings

Contents

- [Exporting trained pLearn models](#export-link)
- [Running exported pLearn models](#run-link)
- [Warnings](#warning-link)

## <a name="export-link"></a>Exporting trained pLearn models

The basice usage for the export script is below.

```
./export_model.sh <path_to_model>
```

The script will place a `exported_model` directory in your ***current directory*** at the time of launching. This directory will contain everything that is required to run your model and as such can be renamed, moved to different directories, or machines. 

Read bellow for more information.

### Path to model & model format

#### Model directory format

The following is an example of what the path and surrounding contents should like.

```
- enviroment.py  # <--- this is REQUIRED for the export script
- interation_39/ # <--- this is what YOU point the export script to
    - (2, 0).h5
    - (2, 60).h5
    - (2, 120).h5 
    - (2, 180).h5
    - (2, 240).h5
    - (2, 300).h5
```

Although the above is an example of the fitted-Q architecture, the export script should work with the standard Q network as well

#### Path to model

The path to the model should be **relative** to the directory you are in when launching the script. So if you had a model in `pLearn/learning_code/models/my_model/iteration_39` and were launching the script from the root level of this repository you would execute...

```
./scripts/export/export_model.sh pLearn/learning_code/models/my_model/iteration_39
```

Or if you were in the `scripts/export` directory...

```
./export_model.sh ../../pLearn/learning_code/models/my_model/iteration_39
```

## <a name="run-link"></a>Running exported pLearn models

After you have an `exported_model` you will want to run it. Below shows the basic usage for runing exported models 

**NOTE**: As of now, the exported models are configured to connect to a shoreside on the docker's host machine's network and only work in Linux versions of docker.

```
./exported_model/run.sh [VEHICLE_FLAG] [TEAM_FLAG] [TIMEWARP] [--build-docker]
```

Running this script will automically:

1. Build a docker image with the proper requirments (if one has not already been build).
    - Built docker image ids are stored in a `pLearn_docker_stub` file.
    - Docker images can be forcibly rebuild with the `--build-docker` flag.
2. Run the `python reinforce.py test` to output a `table.csv` for reading by `BHV_Input`.
3. Launch a vehicle and display `uMAC` output of the vehicle.
4. Upon exit of `uMAC` will stop the container and remove it. 
    - **NOTE:** the docker image will be left untouched. 

## Useful tools

TODO: Docker scripts

## How it works

TODO: Constants wrapper, copying of scripts, docker containers


## <a name="warning-link"></a>Warnings


1. These exported models are currently **ONLY** suitable for use in a Ubuntu OS shoreside running on that os (not in another docker container).
2. The docker container assoicated with the `run.sh` script should not be used to launch multiple vehicles in. If you need to launch multiple vehicles, it would be wise to make two seperate folders `exported_model1` and `exported_model2` and launch both of these. **The reason** is partially due to how the scripts name launched containers and access them... and partial due to the `uMAC targ_*.moos` line in the `scripts/launch_vehicle.sh` script (executed by the run script)
3. Due to the current revision number of moos-ivp that the docker container is referencing, there is a bug with grabing flags. Vehicles will only attempt a flag grab once.


TODO: what is needed to change if someone messes with... the model archtecture... the simulation stuff
