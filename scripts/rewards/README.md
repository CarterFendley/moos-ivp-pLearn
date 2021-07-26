# Reward plotting

<p float="left">
  <img src="pics/rewards_front.png" width="500" />
  <img src="pics/rewards_side.png" width="500" /> 
</p>

## Installing and running 

### Prereqs

You should have some version of `python3` on your OS and install the following dependicies

```
pip3 install matplotlib numpy
```

### Adding your reward function

Copy your `make_rewards` function from `reinforce.py` into `rewards.py` below the following

```
'''
=================================================================
vvvvv Replace the "make_rewards" function and others below vvvvvv
=================================================================
'''
```

**NOTE:** This should include all the dependencies of your function such as `within_goal()` `within_bound()` and `within_tagged` for the default pLearn reward function

Save the file once done

### Running the script

The following command should bring up a 3d visualization of the reward function

```
./rewards.py
```


