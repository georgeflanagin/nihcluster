# members=$(getent group cparish$ | sed 's/^.*://' | sed 's/,/ /g')
set -f
members=(cparish cc7na tg9kt nojaghlo dsiriann ka9xk zc9yv sm8fp ja9hv hg2ki ja5dj ja9ia jjohns2 kv3ws gflanagi)
set +f
for MEMBER in ${members[@]}; do
    echo fixing $MEMBER
    # The tricky part is that we have to communicate the environment of the SUDO-er
    # to the user on whose behalf we will be executing the command.
    # Two steps:
    #    [1] export the current value of MEMBER
    #    [2] preserve the environment with the -E switch on sudo so that $member is passed.
    #
    # The general approach is to change the group ownership on qualifying files
    # and directories first, and then setgid on the directories -- chgrp will 
    # clear the setgid bit, so we have to chgrp *FIRST*.
    
    export member=$MEMBER
    # Change the group of the user's $HOME and $SCRATCH.
    sudo -Eu $member chgrp cparish$ /home/$member || true
    sudo -Eu $member chgrp cparish$ /scratch/$member || true

    # Now, recursively change the group on the contents for all the files that
    # are at least group readable. Repeat the process on /scratch BUT ONLY FOR 
    # THIS USER's FILES. find generates a ton of permission errors, so let's 
    # prevent clutter by sending them to /dev/null
    sudo -Eu $member find /home/$member -user $member -type f -perm -040 -exec chgrp -R cparish$ {} \; || true
    sudo -Eu $member find /scratch -user $member -type f -perm -040 -exec chgrp -R cparish$ {} 2>/dev/null \; || true
    sudo -Eu $member find /home/$member -user $member -type d -perm -050 -exec chgrp cparish$ {} \; || true

    # Enable the setgid bit on the $HOME and $SCRATCH so that new directories will be
    # associated with cparish$ ...
    sudo -Eu $member chmod 2750 /home/$member || true
    sudo -Eu $member chmod 2750 /scratch/$member || true

    # and enable setgid on all the directories in $HOME that were at least
    # group readable so that they stay group readable. Repeat the process on 
    # /scratch. Directories need to be executable to be usable, so we are looking
    # for at least 050 instead of 040.
    sudo -Eu $member find /home/$member -user $member -type d -perm -050 -exec chmod g+s {} \; || true
    sudo -Eu $member find /scratch -user $member -type d -perm -050 -exec chmod g+s {} 2>/dev/null \; || true

    done
