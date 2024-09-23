# -*- coding: utf-8 -*-
"""
This is an example of the kind of data produced by SLURM:

NodeName=spdr01 Arch=x86_64 CoresPerSocket=26
   CPUAlloc=0 CPUTot=52 CPULoad=0.05
   AvailableFeatures=(null)
   ActiveFeatures=(null)
   Gres=(null)
   NodeAddr=spdr01 NodeHostName=spdr01 Version=20.11.8
   OS=Linux 4.18.0-372.19.1.el8_6.x86_64 #1 SMP Mon Jul 18 11:14:02 EDT 2022
   RealMemory=384000 AllocMem=0 FreeMem=351187 Sockets=2 Boards=1
   State=IDLE ThreadsPerCore=1 TmpDisk=0 Weight=1 Owner=N/A MCS_label=N/A
   Partitions=basic,all,cpunodes,communitynodes
   BootTime=2022-08-09T13:55:59 SlurmdStartTime=2022-08-09T13:56:17
   CfgTRES=cpu=52,mem=375G,billing=52
   AllocTRES=
   CapWatts=n/a
   CurrentWatts=0 AveWatts=0
   ExtSensorsJoules=n/s ExtSensorsWatts=0 ExtSensorsTemp=n/s
   Comment=(null)

It is relatively easy for human readers, but more difficult for computer
programs to make sense of. This parser does a better job than a lot of 
string splits.
"""

###
# Credits
###

__author__ = 'George Flanagin'
__copyright__ = 'Copyright 2022, University of Richmond'
__credits__ = None
__version__ = '0.1'
__maintainer__ = 'George Flanagin'
__email__ = 'gflanagin@richmond.edu'
__status__ = 'Teaching Example'
__license__ = 'MIT'

###
# Built in imports.
###

import os
import sys
__required_version__ = (3,8)
if sys.version_info < __required_version__:
    print(f"This code will not compile in Python < {__required_version__}")
    sys.exit(os.EX_SOFTWARE)

###
# Standard imports.
###
import calendar # for leap year.
import datetime # to resolve "now" and large offsets.

###
# Installed imports.
###
try:
    import parsec
except ImportError as e:
    print("stardate_parser requires parsec be installed.")
    sys.exit(os.EX_SOFTWARE)

###
# Project imports.
###
from parser_konstants import *

# These are the simple parsers and regexes.
eq              = lexeme(parsec.string(EQUAL))
comma           = lexeme(parsec.string(COMMA)) | WHITESPACE
null            = lexeme(parsec.string("(null)")).result(None)
na              = lexeme(parsec.string("N/A")).result(None)
ns              = lexeme(parsec.string("n/s")).result(None)
keyname         = lexeme(parsec.regex(r'[a-zA-Z]+'))

linux_version   = parsec.regex(r'Linux .*$')


@parsec.generate
def kv_pair() -> tuple:
    """
    In a general way, look for assignment statements.
    """
    key = yield keyname
    print(f"{key=}")
    yield eq
    value = yield ( timestamp() | 
        time() | 
        integer() | 
        number() | 
        null | 
        na | 
        ns | 
        linux_version | 
        charseq () )
    print(f"{value=}")
    yield comma

    return key, value


# And here is our parser in one line.
slurm_parse = WHITESPACE >> parsec.many(kv_pair)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python slurmparser.py {text|filename}")
        sys.exit(os.EX_USAGE)

    try:
        text = open(sys.argv[1]).read()
    except:
        text = sys.argv[1]

    print(slurm_parse.parse(text))
    sys.exit(os.EX_OK)

