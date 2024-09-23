usage_report()
{
    sudo xfs_quota -x -c 'report -u -ah' /home | cat x | tail -n +5 | sed -e 's!\([KGM]\)\(.*$\)!\1!'
}

