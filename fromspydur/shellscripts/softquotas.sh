function softquotas
{
    if [ $1 ]; then
        users="$1"
    else
        users="$managed_users"
    fi
    MOUNTPOINT="/home"
    QUOTA_LIMIT="10G"

    for username in $users; do
        sudo edquota -p "$QUOTA_LIMIT" -u "$username"
    done
}
