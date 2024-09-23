whoowns()
{
    if [ -z $1 ]; then
        echo "Usage: whoowns /dir/filename"
        return
    fi
    stat -c '%U' "$1"
}

getfile()
{
    if [ -z $1 ]; then
        echo "Usage: getfile /dir/filename"
        return
    fi

    if [ -r "$1" ]; then
        cp "$1" .
    else
        OWNER=whoowns "$1"
        sudo -u $OWNER chmod o+r "$1"
        cp "$1" .
        sudo -u $OWNER chmod o-r "$1"
    fi
}

statfile()
{
    if [ -z $1 ]; then
        echo "Usage: statfile /dir/filename"
        return
    fi 

    if [ -r "$1" ]; then
        stat $1
    else
        thedir=$(dirname "$1")
        OWNER=whoowns "$thedir"
        echo $OWNER owns $thedir
        sudo -u $OWNER chmod o+x "$thedir"
        stat $1
        sudo -u $OWNER chmod o-x "$thedir"
    fi
}
