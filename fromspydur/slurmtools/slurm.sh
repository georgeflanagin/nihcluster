findscript()
{
    sudo -u slurm scontrol show job "$1" | awk -F= '/Command=/{print $2}'
}

nodepower()
{
    if [ -z $2 ]; then
        echo "Syntax: nodepower {on|off} node [ node [ node [ .. ]]]"
        return
    fi

    for node in "$@"; do
        case $node in
            on|off)
                break
            ;;
            
            *)
            sudo cv-power -n spdr$node $1 
            ;;

        esac
    done
}


readscript()
{
    findscript $1 > ~/$1
    cat ~/$1 | less
    rm ~/$1
}

reserve()
{
    if [ -z $2 ]; then
        echo "Usage: reserve {node} for {user[s]} {(lasting|until)} {(duration|date)}"
        echo " "
        echo "Example: reserve 61 for knolin until 2022-12-15"
        echo "        reserves spdr61 for knolin until mid December."
        echo "Example: reserve 51 for perickso lasting 7-00"
        echo "        reserves spdr51 for perickso for 1 week."
        echo " "
        return
    fi

    node="$1"
    users="$3"
    opt="$4"
    time_var="$5"

    case "$opt" in 
        lasting)
            timespec="Duration=$time_var:00:00"
        ;;

        until)
            timespec="EndTime=$time_var"
        ;;
    esac

    sudo -u slurm scontrol create reservation starttime=now \
        Nodes="spdr$node" user="$users" "$timespec"
    if [ ! $? ]; then
        echo "Unable to create reservation."
    fi
}

resume()
{
    if [ -z $1 ]; then
        echo "Usage: resume {node} [node [node ... ]]"
        return
    fi 
    for node in "$@"; do
        sudo -u slurm scontrol update nodename=spdr$node state=resume
    done
}


suspend()
{
    if [ -z $1 ]; then
        echo "Usage: suspend {node} [node [node ... ]]"
        return
    fi
    for node in "$@"; do
        sudo -u slurm scontrol update nodename=spdr$node state=suspend
    done
}

showlog()
{
    sudo -u slurm /usr/bin/tac /var/log/slurm/slurmctld.log | /usr/bin/less
}
