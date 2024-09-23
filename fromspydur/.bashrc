# If this is not an interactive session, bail out.
[ -z "$PS1" ] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
    echo "Loading global bash settings."
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
# source /act/etc/profile.d/actbin.sh
# source /opt/etc/profile.d/pi_cparish.bashrc

# >>>>>>>>>>>>>>>>>>>>>
# names and aliases
# >>>>>>>>>>>>>>>>>>>>>

export anaconda=/usr/local/sw/anaconda/anaconda3
export METABATCHPATH="/usr/local/sw/metabatch"
export EDITOR=`which vim`
export me=`whoami`
export sw=/usr/local/sw
export hpclib="$sw/hpclib"
export rc=/usr/local/etc/usersrc
export mods=/usr/local/sw/modulefiles

shopt -s direxpand
shopt -s cdable_vars
shopt -s checkwinsize

export anaconda=/usr/local/sw/anaconda/anaconda3
export CPUNAME=$(hostname | awk -F. '{print $1}')
# export PS1="["$CPUNAME":\w]: "
alias ll="ls -l "
alias vi="vim "
alias rm="rm -i "
alias mv="mv -i "
alias aws=/usr/local/sw/aws/v2/current/bin/aws
alias aws_completer=/usr/local/sw/aws/v2/current/bin/aws_completer
alias R='R 2>&1 | tee -a r.packages.tombstone.txt'

export alina="ae9qg"
export all_nodes="spdr01 spdr02 spdr03 spdr04 spdr05 spdr06 spdr07 spdr08 spdr09 spdr10 spdr11 spdr12 spdr13 spdr14 spdr15 spdr16 spdr17 spdr18 spdr50 spdr51 spdr52 spdr53 spdr54 spdr55 spdr56 spdr57 spdr58 spdr59 spdr60 spdr61 "


addcats()
{
    cd ~/addcats
    python addcats.py $@
    back
}

as()
{
    if [ -z $1 ]; then
        echo "Usage: as {user} \"{operation}\" "
        return
    fi
    sudo -u "$1" "$2"
}

bump()
{
    if [ -z $1 ]; then
        echo "Syntax: bump {prod|devel}"
        return
    fi
    case $1 in
        'prod'|'devel')
        reassign $sw/slurmtools/slurmplus.conf $sw/slurmtools/slurmplus.$1.conf
        ;;

        *)
        echo "Unknown parameter: $1"
        return
        ;;
    esac

    sudo systemctl restart slurmctld
    sudo -u slurm scontrol reconfig
}

suspendj()
{
    sudo -u slurm scontrol suspend $1
}

resumej()
{
    sudo -u slurm scontrol resume $1
}

proofread()
{
    slurmconfigdir=/usr/local/sw/slurmtools
    command pushd $slurmconfigdir 2>/dev/null
    reassign slurmplus.conf slurmplus.devel.conf
    sudo -u slurm scontrol reconfigure checkconfig=/opt/slurm/slurm.conf
    reassign slurmplus.conf slurmplus.prod.conf
    command popd 2>/dev/null
}

scancel()
{
    if [ -z $1 ]; then
        echo "Usage: scancel {jobid}"
        return
    fi

    jobid="$1"

    if squeue | grep -q $jobid; then
        echo $(squeue | grep $jobid)
        read -p "Is this the job you want to kill (y/n)? " yesorno
        if [ "$yesorno" == "y" ]; then
            sudo -u slurm scancel "$jobid"
        else
            echo "OK, we are NOT canceling $jobid"
        fi
        return
    fi

    echo "$jobid is not running."
}

on_all_nodes()
{
    for node in $all_nodes; do
        echo " "
        echo "on $node:"
        ssh "$node" "$1"
    done
}

findscript()
{
    sudo -u slurm scontrol show job "$1" | awk -F= '/Command=/{print $2}'
}

viewscript()
{
    vi $(sudo -u slurm scontrol show job "$1" | \
        awk -F= '/Command=/{print $2}')
}

undrain()
{
    if [ -z $1 ]; then
        echo "Usage: undrain {nodenumber}"
    fi
    sudo -u slurm scontrol update NodeName="spdr$1" state=RESUME
}

drain()
{
    if [ -z $2 ]; then
        echo "Usage: drain {nodenumber} 'something about why...' "
    fi
    node="$1"
    shift
    sudo -u slurm scontrol update NodeName="$node" state=DRAIN reason="$@"
}


qq()
{
    sudo -u slurm scontrol update jobid="$1" partition="$2"
}

latest()
{
    if [ -z $1 ]; then
        vi $(ls -1rt | tail -1)
    else
        vi $(ls -1rt *.$1 | tail -1)
    fi
}

export slurmwriterhome=~/slurmwriter

slurmwriter()
{
    pushd $slurmwriterhome > /dev/null
    python slurmwriter.py
    popd > /dev/null
}

nodelogin()
{
    if [ -z $1 ]; then 
        echo "Usage nodelogin {partition-name|node} [time-in-hours]"
    else
        hours=${2:-1}
        if [[ $1 =~ ^spdr[0-9]+$ ]]; then
            salloc -w $1 --nodes=1 --mem=10 --cpus-per-task=4 --time=$hours:00:00 
        else
            salloc -p $1 --nodes=1 --mem=10 --cpus-per-task=4 --time=$hours:00:00 
        fi
        # srun --nodes=1 --ntasks=1 --partition basic --pty bash -i 
        # srun --nodes=1 --ntasks=4 --time=0:10:00 --partition "$1" --pty bash -i
    fi
}

getit()
{
    if [ -z $1 ]; then
        echo "Usage: getit host /path/to/files/filespec"
        echo "  creates a directory named /path/to/files on this machine"
        echo "  and then copies the files on <host> in that directory"
        echo "  to this machine."
        return
    fi

    d=$(dirname "$2")
    f=$(basename "$2")
    mkdir -p "$d"
    cd "$d"
    scp -r $1:$d/$f .
    
}


# >>>>>>>>>>>>>>>>>
# directory stuff
# >>>>>>>>>>>>>>>>>

function reassign
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  if [ -z $1 ]; then
   read -p "Give the name of the link: " linkname
  fi
  if [ -z $2 ]; then
   read -p "Give the name of the new target: " target
  fi

  # Make sure the thing we are removing is a sym link.
  if [ ! -L $1 ]; then
   echo "Sorry. $1 is not a symbolic link"

  # attempt to create the file if it does not exist.
  else
   if [ ! -e $2 ]; then
     touch $2
     # mention the fact that we had to create it.
     echo "Created empty file named $2"
   fi

   # make sure the target is present.
   if [ ! -e $2 ]; then
     echo "Unable to find or create $2."
   else
     # nuke the link
     rm -f $1
     # link
     ln -s $2 $1
     # confirm by showing.
     ls -l $1
   fi
  fi
}

function mcd ()
{
    mkdir -p "$1"
    cd "$1"
}

function cd
{
    if [ -z $1 ]; then
        command pushd ~ >/dev/null
    else
        command pushd $(realpath $1) 2>&1 >/dev/null
    fi
}

function cdd
{
    d_name=$(find . -type d -name "$1" 2>&1 | grep -v Permission | head -1)
    if [ -z $d_name ]; then
        d_name=$(find ~ -type d -name "$1" 2>&1 | grep -v Permission | head -1)
    fi  
    if [ -z $d_name ]; then
        echo "no directory here named $1"
        return
    fi
    cd "$d_name"
}

function cdshow
{
    dirs -v -l
}

function up
{
    levels=${1:-1}
    while [ $levels -gt 0 ]; do
        cd ..
        levels=$(( --levels ))
    done
}

function back
{
    levels=${1:-1}
    while [ $levels -gt 0 ]; do
        popd 2>&1 > /dev/null
        levels=$(( --levels ))
    done
}

function clonedirsto()
{
    if [ -z $1 ]; then
        echo "Syntax:"
        echo "   clonedirsto {hostname}"
        echo " copies this directory and all sub-directories to the named host,"
        echo " preserving permissions. ALL FILES ARE IGNORED."
        return
    fi

    opts=" --perms --recursive --verbose --human-readable -f\"+ */\" -f\"- *\" "
    here=$(pwd)
    /usr/bin/rsync $opts $here $1:
}


# >>>>>>>>>>>>>>>>>>>>>>>>>
# sockets, pipes, tunnels
# >>>>>>>>>>>>>>>>>>>>>>>>>

showsockets()
{
    ss -t | grep -v 127.0.0.1
}

showpipes()
{
    lsof | head -1
    lsof | grep FIFO | grep -v grep | grep -v lsof
}

tunnel()
{
    if [ -z $4 ]; then
        echo "Usage: tunnel localport target targetport tunnelhost"
        return
    fi

    ssh -f -N -L "$1:$2:$3 $4"
}


# >>>>>>>>>>>>>>>>>>
# file stuff
# >>>>>>>>>>>>>>>>>>

function perms
{
  if [ -z $1 ]; then
    echo 'Usage: perms {/sufficiently/qualified/directory/or/file/name}'
    return
  fi

  problem="$1"
  if [ "$problem" == "." ]; then
    problem=`pwd`
  fi
  if [ -f "$problem" ]; then
    problem=`readlink -f $problem`
  elif [ -d "$problem" ]; then
    echo ' '
  else
    echo "Cannot make sense of $problem"
    return
  fi

  touch /tmp/x
  rm -f /tmp/x

  tabs 10

  echo "Access permissions for $problem"
  echo "===================================================="
  echo " "

  while true ; do
    if [ -f "$problem" ]; then
      ls -l "$problem" | awk '{print $1"\t"$3"\t"$4"\t"$9}' >> /tmp/x
    else
      ls -ld "$problem" | awk '{print $1"\t"$3"\t"$4"\t"$9}' >> /tmp/x
    fi
    [[ "$problem" != "/" ]] || break
    problem="$( dirname "$problem" )"
  done
  sed '1!G;h;$!d' < /tmp/x
  rm -f /tmp/x
}

xmlfix()
{
    sed -i 's/></>\n</g' "$1"   
}

function owner ()
{
    chown -R $1 *
    chgrp -R $1 *
}

function fixperms()
{
    chmod g+s $(pwd)
    chmod -R go-rwx *
    chmod -R -x+X *
}

hogs()
{
    echo " "
    echo "Hog report for /scratch --- users with more than 1TB"
    ssh spdrstor01 "sudo xfs_quota -x -c 'report -u -ah' /scratch | grep 'T ' | sed 's/T / /' | sort -k2,2n"
    echo " "
    echo "Hog report for /home --- users with more than 1GB"
    ssh spdrstor01 "sudo xfs_quota -x -c 'report -u -ah' /home | grep 'G ' | sed 's/G / /' | sort -k2,2n"
}

function cloc
{
    d=${1:-$(pwd)}
    pushd "$d" >/dev/null 2>&1
    echo "counting $d"
    /sw/canoe/bin/cloc `git ls-tree --full-tree --name-only -r HEAD`
    popd > /dev/null 2>&1
}

# >>>>>>>>>>>>>>>>>>>>>>>>>>
# general functions
# >>>>>>>>>>>>>>>>>>>>>>>>>>

# for fun
alias rot13="tr '[A-Za-z]' '[N-ZA-Mn-za-m]'"

function viremote
{
  if [ -z $1 ]; then
    echo 'Usage: works just like vi, but lets you edit a file on a remote host but with your own .vimrc.'
    return
  fi

  numinnerparams=$(($#-1))

  for last; do true; done
  pushd /tmp > /dev/null 2>&1
  localcopy=${last##*/}
  scp "$last" " $localcopy "
  if [[ $numinnerparams -eq 0 ]]; then
    vi "$localcopy"
  else
    newparams=${@:1:$numinnerparams}
    vi "$newparams" "$localcopy"
  fi
  scp "$localcopy" "$last"
  popd > /dev/null 2>&1
}

function e()
{
    vim `ls -1rt * | tail -1`    
}

function q()
{
    if [ -z $1 ]; then
        squeue --all | sort -k 8 
    else
        squeue --all | grep "spdr$1"
    fi
}

myscreen()
{
    echo "my screen is `tput cols` columns wide and `tput lines` lines tall."
}

function confirm
{
    read -r -p "$1 ... Are you sure? [y/N] " chars
    case $chars in  
        [yY][eE][sS]|[yY])
        true
        ;;  
    *)  
        false
        ;;  
    esac
}

be()
{
    sudo -u $1 bash
}

hg()
{
    if [ -z $1 ]; then
        echo 'Usage: hg {search-term}'
        return
    fi
    history | grep "$1"
}

function editrc
{
  vi ~/.bashrc
  source ~/.bashrc
}

function reload
{
    env -i env
    source /home/installer/.bashrc
}

function randomfile()
{
    if [ -z $1 ]; then
        echo 'Usage: randomfile {filename} [size]'

        echo ' .. generates a random file of printable chars of the given size (in bytes), '
        echo '  or 1000 bytes if not supplied.'
        return
    fi
  
    len=${2:"1000"}
    < /dev/urandom tr -dc "\t\n [:alnum:]" | head -c $len | base64 | head -c $len > "$1"
}

function myhosts()
{
    cat ~/.ssh/config | grep ^Host
}

function isrunning
{
    ps -ef | sed -n "1p; /$1/p;" | grep -v 'sed -n'
}

function findtext 
{
    grep -n -R "$1" * 2>/dev/null | grep -v "Binary file" 
}

########################################

# >>>>>>>>>>>>>>>>>>
# PATH stuff
# >>>>>>>>>>>>>>>>>>
function addhere
{
  export PATH=$PATH:`pwd`
  echo PATH is now $PATH
}

function delhere
{
  HERE=:`pwd`
  export PATH=$(echo $PATH | sed "s/$HERE//")
  echo PATH is now $PATH
}

function pyaddhere
{
    export PYTHONPATH="$PYTHONPATH":`pwd`
    echo PYTHONPATH="$PYTHONPATH"   
}

function pydelhere
{
    HERE=:`pwd`
    export PYTHONPATH=$(echo $PYTHONPATH | sed "s/$HERE//")
    echo PYTHONPATH="$PYTHONPATH"
}

function libaddhere
{
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PWD"
    echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
}

function libdelhere
{
    HERE=:`pwd`
    export LD_LIBRARY_PATH=$(echo $LD_LIBRARY_PATH | sed "s/$HERE//")
    echo LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
}

# >>>>>>>>>>>>>>>>>>>
# postgres stuff
# >>>>>>>>>>>>>>>>>>>


function postgres_start
{
    sudo systemctl postgresql-13 start
}

function postgres_stop
{
    sudo systemctl postgresql-13 stop
}

function postgres_restart
{
    postgres_stop
    postgres_start
}

function pg
{
    sudo -u postgres $@
}

# >>>>>>>>>>>>>>>>>>>
# Keyring stuff
# >>>>>>>>>>>>>>>>>>>
export config=~/.ssh/config

gpgdiagnose()
{
    if [ -z $1 ]; then
        echo "Usage: gpgdiagnose filename"
        return
    fi
    
    gpg --list-packets -vvv --show-session-key "$1" > "$1.diag" 2>&1
}

findkey()
{
    if [ -z $1 ]; then
        echo "Usage: findkey {ownername}"
        return
    fi
    gpg --list-keys | grep -a1 -b1 "$1"
}

function key
{
    if [ -z $1 ]; then
        cat - <<EOF
Usage: key {command} {keyname}"
   where command is one of:

        help -- get a lot of help!

        ur       -- creates an exportable copy of the UR key[s]
                    to send to another party. The file will be
                    named ur.key.pub in the current directory.
                    
        find     -- locate a key by user ID
        finger   -- print the complete finger print of the key and
                    all its subkeys.
        details  -- show everything about the key
        sign     -- sign the key with the UR key

EOF
        return
    fi

    case "$1" in
        
        help)
        cat - <<EOD | less
This utility shows information about a key. To use it, you need to know
the "user id" associated with the key, and that is usually the email 
address of the key's owner.

To locate a key: 

> key find presence

4784-pub   2048R/146FAEB8 2017-07-25
4816:uid                  Presence <hello@presence.io>
4866-sub   2048R/C295C0BA 2017-07-25

In the example, the top line contains `146FAEB8`. Those are the last eight
hex digits of the key's ID. 

To see the details of key 146FAEB8, do the following. Only the first few
lines are shown, and all keys should contain similar information near
the top of the listing of the details. Line numbers have been added on
the right for clarity.

**************************************************************************
ACHTUNG! The info can be long, so the output is routed to less so that you
can scroll it backwards and forwards.
**************************************************************************

> key details 146FAEB8

:public key packet:                                           1
    version 4, algo 1, created 1501003658, expires 0          2
    pkey[0]: [2048 bits]                                      3
    pkey[1]: [17 bits]                                        4
    keyid: AD0AD21B146FAEB8                                   5
:user ID packet: "Presence <hello@presence.io>"               6
:signature packet: algo 1, keyid AD0AD21B146FAEB8             7

[ .. deleted to save space .. ]

Line 1: the type of key "public".
Line 2: the creation date in seconds since Jan 1, 1970. 
    1501003658 is sometime on July 25th, 2017. Note that you
    can convert this exactly with the following command:

> date --date='@1501003658'

Tue Jul 25 13:27:38 EDT 2017

Line 5: the full sixteen hex digit ID of the key.
Line 6: the key's owner, in full.
Line 7: every valid key has at least one signature, and this
    is the self signature. 


If we believe the key is valid, we sign the key with the UR key.

> key sign 146FAEB8

EOD
            ;;

        ur)
            gpg -a --export 0x7ED95717 > ur.key.pub
            ;;


        find)
            if [ -z "$2" ]; then
                echo "You must give the name of the key you want to find."
                return
            fi

            gpg --list-keys | grep -a1 -b1 "$2"
            ;;
    
        details)
            if [ -z "$2" ]; then
                echo "You must give the name of the key to see its details."
                return
            fi
         
            gpg -a --export "$2" | gpg --list-packets | less
            ;;


        finger)
            if [ -z "$2" ]; then
                echo "You must give the name of the key to see its details."
                return
            fi

            gpg --fingerprint --fingerprint "$2"
            ;;

        sign)
            if [ -z "$2" ]; then
                echo "You must give the ID of the key to sign."
                return
            fi

            gpg -u 0x7ED95717 --yes --sign-key "$2" 
            ;;

        *)

            echo "Sorry, there is no command named $1"
            ;;

    esac
}


function readpower
{
    command pushd $sw/readpower >/dev/null
    if [ -z $1 ]; then
        echo "Using defaults"
        python readpower.py
    elif [ $1 == "-?" ]; then
        python readpower.py --help
    else
        python readpower.py $@
    fi
    command popd >/dev/null
}

export LS_COLORS=$LS_COLORS:'di=0;35:'
export HISTTIMEFORMAT="%y/%m/%d %T "
PROMPT_COLOR=$PURPLE

# Find out if git is around.
if [ ! -z `which git 2>/dev/null` ]; then
    echo "git is installed on this system; loading shortcuts."
    source git.bash 2>&1 >/dev/null
else
    echo "Cannot find git in the PATH"
fi

isinstalled()
{
    rpm -qa "$1"\*
}

whoisin()
{
    # Shell function to show users in a named group 
    # and the date of the last activity.
    #
    #  Usage: whoisin [group]
    out=/tmp/whoisin
    rm -f $out
    touch $out
    export g=${1:-cparish$}
    echo "Looking at users in group $g"
    echo " "
    export members=`getent group $g`
    IFS=',' read -ra MEMBERS <<< "$members"
    for member in "${MEMBERS[@]}" ; do
        if [ -d "/home/$member" ]; then
            line=`date -r "/home/$member" +'%F %T'`
            echo $member $line >> $out
        fi 
    done
    cat $out | sort
    rm -f $out
}    

function backup
{
    cd ~/clusterbackup
    python clusterbackup.py $@
    back
}

function installslurm
{
    cd
    ./installslurm.bash $@ | tee > installslurm.`date --iso-8601=minutes`.out
    back
}

function uninstallslurm
{
    cd 
    ./uninstallslurm.bash $@ | tee > uninstallslurm.`date --iso-8601=minutes`.out
    back
}


# Find out if slurm is present.
if [ ! -z `which sbatch 2>/dev/null` ]; then
    echo "slurm is installed on this system; loading shortcuts"
    source slurm.bash 2>&1 >/dev/null
    source slurm_completion.sh
else
    echo "Cannot find sbatch in the PATH"
fi

if [ -f "$HOME/.localrc" ]; then
    source .localrc
fi


autoslurm()
{
    export PYTHONPATH=/usr/local/sw/hpclib.dev
    # Instead of using $OLDPWD as the location we came from to run
    # autoslurm, let's set an environment variable so that we can
    # know that this shell function launched autoslurm.
    export AUTOSLURM_DEFAULT_DIR=$(realpath $PWD)
    command pushd /usr/local/sw/autoslurm.dev >/dev/null
    python autoslurm.py --dryrun $@
    command popd >/dev/null
}

can()
{
    if [ -z $2 ]; then
        echo "Usage: can {read|write|execute} {file-or-dir}"
        return
    fi

    case "$1" in 

        read|r)
            test -r "$2"
            result=$?
        ;;

        write|w)
            test -w "$2"
            result=$?
        ;;

        execute|x)
            test -x "$2"
            result=$?
        ;;

        *)
            echo "Unknown mode $1"
            return
        ;;
    esac

    if [[ $result == 0 ]]; then
        echo "yes"
    else
        echo "no"
    fi
}


export SLURM=$sw/slurmtools
export PYTHONPATH="$sw/hpclib"
export PATH="$sw/aws:$PATH"
export AWS_SHARED_CREDENTIALS_FILE="$HOME/.aws/credentials"
export BACKUPHOME="$HOME"
export OPENAI_API_KEY='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'

# source $rc/xrun.rc

function kibitz
{
export OLDPATH="$PATH"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
kibitz $@
export PATH="$OLDPATH"
}


function spydurview
{
    old_python_path="$PYTHONPATH"
    export PYTHONPATH=/usr/local/sw/hpclib
    command pushd ~/spydurview.george >/dev/null
    python spydurview.py
    command popd >/dev/null
    export PYTHONPATH="$old_python_path"
}

function regroup
{
    if [ -z $2 ]; then
        echo 'Usage: regroup {dir} {groupname}'
        return
    fi

    d="$1"
    g="$2"
    chgrp -R -v "$g" "$d"
    chmod -R -v a+rX "$d"
    chmod -R -v g+wrX "$d"
    command find "$d" -type d -exec chmod -v g+s {} \;
}

source condafy.sh

sinfo
squeue --all | sort -k 8
export s22=$sw/summer2022
export PATH="$PATH:/usr/local/sw/anaconda/anaconda3/bin/python"

source $SLURM/slurm.sh

function trappipe
{
    :   
}

trap trappipe SIGPIPE

function pipereader
{
    while :; do
        echo $(< ./metapipe)
    done
}


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/usr/local/sw/anaconda/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/usr/local/sw/anaconda/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/usr/local/sw/anaconda/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/usr/local/sw/anaconda/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export all_users=$(ls -1d /home/* | sed 's!/home/!!g' | tr '\n' ' ')
export managed_users=$(getent group managed | sed 's/managed:x:1900://' | sed 's/,/ /g')

inuse()
{
    sudo -u "$1" find -user $1 -type f -exec du -chs {} + 
}

# Search a range of ports for something not in use.
function open_port
{
    lower=${1:-9000}
    upper=${2:-9100}

    for ((port = $lower; port <= $upper; port++)); do
        if ! ss -tuln | grep -q ":$port "; then
            next_open_port="$port"
            break
        fi
    done
}

usage_report()
{
    sudo xfs_quota -x -c 'report -u -ah' /home
    sudo xfs_quota -x -c 'report -u -ah' /scratch
}

slurmprod ()
{
    pushd /usr/local/sw/slurmtools >/dev/null
    reassign slurmplus.conf slurmplus.prod.conf
    popd >/dev/null
}

slurmdev ()
{
    pushd /usr/local/sw/slurmtools >/dev/null
    reassign slurmplus.conf slurmplus.devel.conf
    popd >/dev/null
}

source ~/wstools.bash
source ~/elastic.bash
cd ~

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
