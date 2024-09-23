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
