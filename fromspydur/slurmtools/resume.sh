#!/bin/bash -e

cd /usr/local/sw/slurmtools
export PATH="$PATH:/usr/local/sw/anaconda/anaconda3/bin"
export PYTHONPATH=/usr/local/sw/hpclib

remove="spdr"
node=$1
node=${node#"$remove"}

python node_on.py --node $((node))
