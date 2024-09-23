me=`whoami`
chmod 711 $HOME
if [ -z $2 ]; then
    echo "Usage: makedirpair {dirname} {groupname}"
    echo " "
    echo "  Creates a directory under $HOME named {dirname} that can"
    echo "  be used by both $me and the members of {groupname}. The"
    echo "  command creates a pair of sub-directories named 'shared' and"
    echo "  'readonly'. The first is read-write by members of {groupname}"
    echo "  and the second is writeable only by $me."
    exit
fi

d="$1"
g="$2"
# See if the group exists.
if [ ! $(getent group $g) ]; then
    echo "Sorry, but the group $g does not yet exist. Contact"
    echo "hpc@richmond.edu to have it created."
    exit
fi

# And you need to be a member of the group.
if groups "$me" | grep -q "$g"; then
    true
else
    echo "Sorry, but you are not a member of $g"
    echo "If you think this is a mistake, contact hpc@richmond.edu"
    exit
fi 

# Make sure the command is executable from any directory that
# happens to be PWD at the moment.
command pushd $HOME >/dev/null

# The -p parameter will ensure the command works even if the
# directories have already been created.
mkdir -p "$d"

# Set the group association to the indicated group.
chgrp "$g" "$d"

# Set the GID bit so that new files and directories will inherit
# the group association instead of being associated with the
# primary group of the creator of the file or directory. 
chmod 2770 "$d"

# The shared directory will be writeable by the group.
mkdir -p "$d/shared"
chmod 770 "$d/shared"

# The readonly directory will be read by the group; writeable
# only by the owner, you.
mkdir -p "$d/readonly"
chmod 750 "$d/readonly"

# Show what happened.
if [ ! $(which tree) ]; then
    ls -ld "$d"
    ls -l  "$d"
else
    tree -pf "$d"
fi

# Return the user to wherever this command was initiated.
command popd >/dev/null     
