managed_users=$(whoisin managed | tail -n +2 | sed 's/ .*$//')



inuse()
{
    sudo -u "$1" du -sh "/home/$1" 
}

for u in $managed_users; do
    sudo -u "$u" du -sh "/home/$u"
done

