#!/usr/bin/env python3
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np

import os, sys
currentdir = os.path.dirname(os.path.realpath(__file__))
learning_codedir = os.path.join(currentdir, '../../pLearn/learning_code')
sys.path.append(learning_codedir)

from Constants import Constants
Constants=Constants()

'''
=================================================================
vvvvv Replace the "make_rewards" function and others below vvvvvv
=================================================================
'''

def make_rewards(smooth = True):
    """
    make reward function. This part is very important to making the 
    model work correctly. Due to sparse rewards, try giving scalled down
    rewards some distance from the actual reward point. Also negative 
    rewards for going out of bounds
    """
    if smooth:
        def reward_fn(state):
            return within_goal(state)+within_bound(state)+within_tagged(state)
    else:
        def reward_fn(state):
            #check within bounds (first priority)
            boundary_dist=min(state[Constants.state["leftBound"].index],
                            state[Constants.state["rightBound"].index],
                            state[Constants.state["upperBound"].index],
                            state[Constants.state["lowerBound"].index])
            if(boundary_dist < 5):
                return Constants.neg_reward

            enemy_dist=state[Constants.state["enemy_dist"].index]
            if(enemy_dist < 5):
                return Constants.neg_reward

            dist=state[Constants.state["flag_dist"].index]
            discount = Constants.reward_dropoff
            return Constants.max_reward*discount**(max(0, dist))
            
            
        
    return reward_fn

    
def within_goal(state):
   """
   helper function to give a reward based on proximity to the goal state (flag)
   """
   reward_dropoff=Constants.reward_dropoff
   dist=state[Constants.state["flag_dist"].index]
   if state[Constants.state["out"].index] != 1:
        value = min(max(dist-Constants.max_reward_radius, 0), 200)
        return float(Constants.max_reward)*reward_dropoff**value
   else:
        return 0 

def within_bound(state):
   """
   helper function to give a negative reward based on proximity to the boundary
   """
   boundary_dist=min(state[Constants.state["leftBound"].index],
            state[Constants.state["rightBound"].index],
            state[Constants.state["upperBound"].index],
            state[Constants.state["lowerBound"].index])

   if boundary_dist == state[Constants.state["leftBound"].index]:
       if boundary_dist < 5:
           return -1.5*Constants.max_reward-boundary_dist*(-1.5*Constants.max_reward/10)
       else:
           return 0
       
   elif boundary_dist < 20:
       return Constants.neg_reward-boundary_dist*(Constants.neg_reward/20)
   
   else:
       return 0

def within_tagged(state):
   """
   helper function to give a reward based on proximity to the goal state (flag)
   """
   enemy_dist=state[Constants.state["enemy_dist"].index]
   if state[Constants.state["out"].index] == 1:
       return Constants.neg_reward
   elif enemy_dist < 8:
       return Constants.neg_reward
   elif enemy_dist < 30:
       return Constants.neg_reward-enemy_dist*(Constants.neg_reward/30)
   else:
       return 0

'''
=================================================================
^^^^^ Replace the "make_rewards" function and others below ^^^^^^
=================================================================
'''

'''
====================================
DO NOT TOUCH BELOW
unless you really want then go ahead
====================================
'''

def plot():
  # -------------------------
  # Part 1: Get reward values

  FLAG = np.asarray((-58,-71))
  TOP_RIGHT = np.asarray((56,16))
  TOP_LEFT = np.asarray((-83,-49))
  BOTTOM_LEFT = np.asarray((-53,-114))
  BOTTOM_RIGHT = np.asarray((82,-56))

  def d_to_upper(p):
    return np.cross(TOP_RIGHT-TOP_LEFT, p-TOP_LEFT)/np.linalg.norm(TOP_RIGHT-TOP_LEFT)

  def d_to_lower(p):
    return np.cross(BOTTOM_RIGHT-BOTTOM_LEFT, p-BOTTOM_LEFT)/np.linalg.norm(BOTTOM_RIGHT-BOTTOM_LEFT)

  def d_to_left(p):
    return np.cross(TOP_LEFT-BOTTOM_LEFT, p-BOTTOM_LEFT)/np.linalg.norm(TOP_LEFT-BOTTOM_LEFT)

  def d_to_right(p):
    return np.cross(TOP_RIGHT-BOTTOM_RIGHT, p-BOTTOM_RIGHT)/np.linalg.norm(TOP_RIGHT-BOTTOM_RIGHT)

  def d_to_flag(p):
    return abs(np.linalg.norm(FLAG-p))

  x_pos = []
  y_pos = []
  v_pos = []

  reward_function = make_rewards()

  # Scan over the range in which the feild is defined
  for x in range(-85,85, 2):
    for y in range(-115, 20, 2):
      # Get the distances to borders
      d_upper = d_to_upper((x,y))
      d_lower = d_to_lower((x,y))
      d_left = d_to_left((x,y))
      d_right = d_to_right((x,y))
      
      # Only process points which are in bounds of the feild
      if d_upper < 0 and d_lower > 0 and d_left < 0 and d_right > 0:
        d_flag = d_to_flag((x,y))

        # Construct state to be passed to make_rewards
        state = [50]*12 # TODO: Auto build this 50 cause want distances to be far idk

        # Define distances to boundrys
        state[Constants.state["leftBound"].index] = abs(d_left)
        state[Constants.state["rightBound"].index] = abs(d_right)
        state[Constants.state["upperBound"].index] = abs(d_upper)
        state[Constants.state["lowerBound"].index] = abs(d_lower)
        
        # Make distance to enemy large as this script can't handl that well
        state[Constants.state["enemy_dist"].index] = 100

        state[Constants.state["flag_dist"].index] = d_flag
        state[Constants.state["out"].index] = 0 # In bounds
        
        reward = reward_function(state)

        v_pos.append(reward)
        x_pos.append(x)
        y_pos.append(y)

  # -------------------------------
  # Part 2: Plotting
  fig = plt.figure()
  ax = plt.axes(projection='3d')

  # Do the plotting
  ax.plot([56,-83,-53,82,56], [16,-49,-114,-56,16], 'red', linewidth=4)
  ax.plot_trisurf(x_pos, y_pos, v_pos)

  plt.show()

if __name__ == '__main__':
  plot()