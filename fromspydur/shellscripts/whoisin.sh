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
