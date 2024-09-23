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
def node_on_main(myargs:argparse.Namespace) -> int: 
    #open a file to write the results of operation in
    #note_status = open("powersave.log", "a")
    #check the status of the node and log a message into the file
    note_status="powersave.log"
    with contextlib.redirect_stderr(open(note_status, "a")):

        tombstone(f"Starting up node {myargs.node}")

        result = slurmutils.node_start(myargs.node)
        tombstone(f"Start command sent {result=}. Waiting 180 seconds to check status.")
        time.sleep(180)
        
        if slurmutils.node_powerstatus(myargs.node)==1: 
            tombstone(f"Node {myargs.node} is started.")
            slurmutils.node_sync(myargs.node)
            tombstone(f"Node {myargs.node} is sync-ed.")

        else:
            tombstone(f"Node {myargs.node} is still off.")
            return os.EX_UNAVAILABLE
    
    return os.EX_OK


if __name__ == '__main__':
    
    parser = argparse.ArgumentParser(prog="node_on", 
        description="What node_on does, node_on does best.")

    parser.add_argument('-n', '--node', type=int, required=True,
        help="Input file name.")
    parser.add_argument('-o', '--output', type=str, default="",
        help="Output file name")
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

