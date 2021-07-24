from environment import Constants as Constants_Original
from environment import State

import os

CURRENT_DIRECTORY = os.path.dirname(os.path.abspath(__file__))

class Constants(Constants_Original):
      '''
      This class wraps the original constants class as
      to provide dynamic paths which are updated to
      point to the directory in which the exported model
      is contained.

      Only paths which are relivant to running trained
      models are modified.
      '''
      def __init__(self):
            Constants_Original.__init__(self)
            
            self.out_address = os.path.join(
                  CURRENT_DIRECTORY,
                  "mission/m200/table.csv")
            
            self.test_address = os.path.join(
                  CURRENT_DIRECTORY,
                  'model')
            
            # pLearn will break without this
            self.save_model_dir = os.path.join(
                  CURRENT_DIRECTORY,
                  '.dummy_save_dir'
            )
            


# For testing purposes...
if __name__ == '__main__':
      c = Constants()
      print("Out Address: "+c.out_address)
      print("Test Address: "+c.test_address)