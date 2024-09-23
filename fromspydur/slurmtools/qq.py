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
import cmd
import contextlib
import getpass
mynetid = getpass.getuser()

###
# From hpclib
###
import linuxutils
import slurmutils
from   urdecorators import trap

###
# imports and objects that are a part of this project
###
import qq_tools

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



class QQ(cmd.Cmd): 
    
    def __init__(self):

        cmd.Cmd.__init__(self)
        self.most_recent_cmd = ''
        self.prompt = "\n[QQ]: "

    def default(self, args:str="") -> object:
        
        if args.strip().lower() in ('stop', 'quit', 'exit'):
            sys.exit(os.EX_OK)

        if args.startswith('!'):
            return os.system(args[1:])

        try:
            self.most_recent_cmd = args
            return qq_tools.qq_executive(args)

        except KeyBoardInterrupt as e:
            print("You pressed control-c. Exiting")
            sys.exit(os.EX_OK)

        except parsec4.ParseError as e:
            return (f"'{args}' contains a syntax error.")


@trap
def qq_main(myargs:argparse.Namespace) -> int:

    console = QQ()
    console.cmdloop(intro=f" QQ: the SLURM re-Queueing utility.")

    return os.EX_OK


if __name__ == '__main__':
    
    parser = argparse.ArgumentParser(prog="qq", 
        description="What qq does, qq does best.")

    myargs = parser.parse_args()

    try:
        outfile = sys.stdout if not myargs.output else open(myargs.output, 'w')
        with contextlib.redirect_stdout(outfile):
            sys.exit(globals()[f"{os.path.basename(__file__)[:-3]}_main"](myargs))

    except Exception as e:
        print(f"Escaped or re-raised exception: {e}")

