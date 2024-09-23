#!/bin/bash -e
/usr/bin/squeue --format "%i" | tail -n +2 > /home/installer/suspend.jobs.txt
jobids=$(cat /home/installer/suspend.jobs.txt)
for j in $jobids; do 
    sudo -u slurm /usr/bin/scontrol suspend "$j"
done
mailx -s "suspended jobs" -a /home/installer/suspend.jobs.txt hpc@richmond.edu < /dev/null
