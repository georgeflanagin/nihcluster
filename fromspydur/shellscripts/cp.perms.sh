users="mr3ru ab9tm kv3ws zc9yv jjohns2 sm8fp mh8sz ja9hv dsiriann tg9kt mh9vw nojaghlo cc7na ja9ia hg2ki va6hp jmuya kl6za ih6mg fm7rj cb9sy msamir"

chm=`which chmod`
for user in $users; do
    echo "expanding permissions for $user"
    sudo -u $user chmod o+rx /home/$user
    sudo -u $user chmod -R o+rx /home/$user/*
done
