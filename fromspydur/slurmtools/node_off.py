# -*- coding: utf-8 -*-
import typing
from   typing import *

min_py = (3, 8)

###
# Standard imports, starting with os and sys
###
import os
import sys
if sys.version_info < min_py:
    print(f"This program requires Python {min_py[0]}.{min_py[1]}, or higher.")
    sys.exit(os.EX_SOFTWARE)

###
# Other standard distro imports
###
import argparse
import contextlib
import getpass
mynetid = getpass.getuser()
import time

###
# From hpclib
###
import linuxutils
from   tombstone import tombstone
from   urdecorators import trap

###
# imports and objects that are a part of this project
###
import slurmutils
verbose = False

###
# Credits
###
__author__ = 'George Flanagin'
__copyright__ = 'Copyright 2022, University of Richmond'
__credits__ = None
__version__ = 0.1
__maintainer__ = 'George Flanagin'
__email__ = 'gflanagin@richmond.edu'
__status__ = 'in progress'
__license__ = 'MIT'


@trap
def node_off_main(myargs:argparse.Namespace) -> int:
  note_status = "powersave.log"
  node = myargs.node

  with contextlib.redirect_stderr(open(note_status, "a")):

    tombstone(f"Begin power off of {node=}.")

    if not slurmutils.node_busy(node):
        tombstone(f"Node {node} set to drain") 
        slurmutils.node_drain(node)
        result = slurmutils.node_stop(node)
        tombstone(f"Node {node} sent stop signal. Waiting {myargs.wait} seconds.") 
        time.sleep(myargs.wait)
    else:
        tombstone(f"Node {node} cannot be turned off. It is running a job.")      
        return os.EX_DATAERR
        
    if (result := slurmutils.node_powerstatus(node)):
        tombstone(f"Node {node} is still on.")
        return os.EX_IOERR
    else:
        tombstone(f"Node {node} is off now.")

  return os.EX_OK


if __name__ == '__main__':
    
    parser = argparse.ArgumentParser(prog="node_off", 
        description="What node_off does, node_off does best.")

    parser.add_argument('-n', '--node', type=int, default="",
        help="Node number to power down.")
    parser.add_argument('-o', '--output', type=str, default="",
        help="Output file name")
    parser.add_argument('--wait', type=int, default=60,
        help="Number of seconds to wait for shutdown. Default is 60.")
    parser.add_argument('-v', '--verbose', action='store_true',
        help="Be chatty about what is taking place")


    myargs = parser.parse_args()
    verbose = myargs.verbose

    try:
        outfile = sys.stdout if not myargs.output else open(myargs.output, 'w')
        with contextlib.redirect_stdout(outfile):
            sys.exit(globals()[f"{os.path.basename(__file__)[:-3]}_main"](myargs))

    except Exception as e:
        print(f"Escaped or re-raised exception: {e}")

