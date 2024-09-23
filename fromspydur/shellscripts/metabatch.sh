function trappipe
{
    :   
}

trap trappipe SIGPIPE

function sbatch
{
    echo "$(whoami),$1" > metapipe    
}

function pipereader
{
    while :; do
        echo $(< ./metapipe)
    done
}


