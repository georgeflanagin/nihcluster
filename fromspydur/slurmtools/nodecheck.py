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
from   collections import namedtuple
import contextlib
import getpass
mynetid = getpass.getuser()
from   pprint import pprint
import smtplib

###
# From hpclib
###
from   dorunrun import dorunrun
import linuxutils
from   sloppytree import SloppyTree
from   urdecorators import trap

###
# imports and objects that are a part of this project
###
verbose = False

###
# Credits
###
__author__ = 'George Flanagin'
__copyright__ = 'Copyright 2023, University of Richmond'
__credits__ = None
__version__ = 0.1
__maintainer__ = 'George Flanagin'
__email__ = 'gflanagin@richmond.edu'
__status__ = 'in progress'
__license__ = 'MIT'


Row = namedtuple('Row', 'partition avail timelimit nodes state nodelist')
good_states = "alloc* comp* futr* idle* maint* mix* npc* plnd* pow_dn* pow_up* resv*"

@trap
def nodecheck_main(myargs:argparse.Namespace) -> int:
    result = SloppyTree(dorunrun('/usr/bin/sinfo', return_datatype=dict))
    if not result.OK: 
        return send_message(f"sinfo check failed with code {result.code}. {result.stderr}") | os.EX_IOERR

    # Drop the header, and make a table out of the data. We don't need the 
    # whole table at once, so make it a generator.
    table = ( Row(*line.split()) for line in result.stdout.split('\n')[1:] )

    # And make the message by join-ing the lines created by another pair of 
    # nested generators.
    message = "\n".join(" ".join(r) for r in table if r.state not in good_states)
    verbose and len(message) and print(message)
    return send_message(message) if len(message) else os.EX_OK


@trap
def send_message(text:str) -> int:

    msg = f"""From: hpc@richmond.edu
To: hpc@richmond.edu
Subject: Nodes are down on Spydur

{text}"""

    server = smtplib.SMTP('localhost')
    server.sendmail('hpc@richmond.edu', 'hpc@richmond.edu', msg)
    server.quit()

    return os.EX_OK


if __name__ == '__main__':
    
    parser = argparse.ArgumentParser(prog="nodecheck", 
        description="What nodecheck does, nodecheck does best.")

    parser.add_argument('-i', '--input', type=str, default="",
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

