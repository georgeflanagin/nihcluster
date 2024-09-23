
IFS=,
for f in $(getent group faculty)
do
    d="/usr/local/etc/usersrc/$f"
    mkdir -p $d
    chgrp faculty $d
    chmod 2775 $d
    touch $d/my.rc
done
