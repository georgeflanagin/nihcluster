set -x
# Array of the netids you gave me.
students=("cc7na" "ja9ia" "nojaghlo" "hg2ki" "mr3ru" "mh9vw" "ab9tm" "kv3ws" "zc9yv" "jjohns2" "sm8fp" "mh8sz" "ja9hv" "dsiriann" "tg9kt")

for s in ${students[@]}; do
    # add everyone to the managed group first.
    sudo /usr/local/sbin/hpcmanage $s

    # Make sure they are in your group. It is not an error
    # to add someone twice; doing so has no further effect.
    sudo /usr/local/sbin/hpcgpasswd -a "$s" cparish

    # change the group of $HOME to cparish
    sudo -u $s chgrp cparish /home/$s

    # Set the perms on $HOME to the correct value
    # 2 : new files and dirs will also be associated with cparish
    # 7 : owner rwx
    # 1 : group x .. group members can cd into the directory.
    # 1 : world x .. everyone can cd into the directory.
    sudo -u $s chmod 2751 /home/$s

    # If they have a $SCRATCH dir already, this will not hurt.
    sudo -u $s mkdir -p /scratch/$s
    
    # And set the perms on $SCRATCH to the correct value.
    sudo -u $s chgrp cparish /scratch/$s
    sudo -u $s chmod 2771 /scratch/$s

    # Go to $HOME and recursively change the group to cparish,
    # then set the perms.
    # g+rX : add read to group; add x only if the file is x by owner.
    #        this prevents making non-executable files executable.
    sudo -u $s chgrp -R cparish /home/$s
    sudo -u $s chmod -R g+rX /home/$s

    # Do the same thing for $SCRATCH
    sudo -u $s chgrp -R cparish /scratch/$s
    sudo -u $s chmod -R g+rX /scratch/$s

    # And the tricky part .. We need to recursively setgid
    # on the directories. This will tie the group of all new
    # files to cparish.
    sudo -u $s find /scratch/$s -type d -exec chmod g+s {} \;
    sudo -u $s find /home/$s -type d -exec chmod g+s {} \;
done
set +x
