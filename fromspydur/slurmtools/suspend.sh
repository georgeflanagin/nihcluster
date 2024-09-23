#!/bin/bash -e

cd /usr/local/sw/slurmtools
export PATH="$PATH:/usr/local/sw/anaconda/anaconda3/bin"
export PYTHONPATH=/usr/local/sw/hpclib

remove="spdr"
node=$1
node=${node#"$remove"}

/usr/bin/time python node_off.py --node $((node)) >> output 2>>errors 
