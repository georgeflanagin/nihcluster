findscript()
{
    sudo -u slurm scontrol show job "$1" | awk -F= '/Command=/{print $2}'
}

suspend_all()
{
    squeue --format "%i" | tail -n +2 > suspend.jobs.txt
    jobids=$(cat suspend.jobs.txt)
    for j in $jobids; do 
        echo $j
        sudo -u slurm scontrol suspend "$j"
    done
}

resume_all()
{
    jobids=$(cat suspend.jobs.txt)
    for j in $jobids; do 
        sudo -u slurm scontrol resume $j
    done 
}
