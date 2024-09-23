#!/bin/bash

# Specify the node to check
NODE=spdr60

# Get the total memory of the node
TOTAL_MEM=$(scontrol show node $NODE | grep RealMemory | awk '{print $2}' | cut -d= -f2)

# Get the list of jobs running on the node and their memory requests
JOBS=$(squeue -h -o "%.18i %.10M %.6D" -w $NODE)

# Initialize the sum of memory requests
SUM_MEM_REQUESTED=0

# Iterate over each job and sum the memory requests
while read -r JOB_ID MEM_REQUESTED NODES; do
  # Remove 'M' or 'G' suffix and convert to MB if necessary
  if [[ $MEM_REQUESTED == *G ]]; then
    MEM_REQUESTED_MB=$(echo $MEM_REQUESTED | sed 's/G//' | awk '{print $1 * 1024}')
  elif [[ $MEM_REQUESTED == *M ]]; then
    MEM_REQUESTED_MB=$(echo $MEM_REQUESTED | sed 's/M//')
  else
    MEM_REQUESTED_MB=0
  fi

  # Add to the total requested memory
  SUM_MEM_REQUESTED=$((SUM_MEM_REQUESTED + MEM_REQUESTED_MB))
done <<< "$JOBS"

# Output the results
echo "Total memory on $NODE: $TOTAL_MEM MB"
echo "Total memory requested on $NODE: $SUM_MEM_REQUESTED MB"

if [ $SUM_MEM_REQUESTED -gt $TOTAL_MEM ]; then
  echo "Node $NODE is oversubscribed."
else
  echo "Node $NODE is not oversubscribed."
fi

