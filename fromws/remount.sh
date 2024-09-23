/bin/mount -a
if [ ! $? ]; then
    /usr/bin/mailx -s "mount failed for $(/usr/bin/whoami) on $(/usr/bin/hostname -s)" hpc@richmond.edu </dev/null >/dev/null 2>&1
fi
