managed_users=$(cat managed_users)
rm -f user.commands.txt
set +e
for u in $managed_users; do
    sudo -u $u cat "/home/$u/.bash_history" >> user.commands.txt
done
set -e

#sort < /tmp/user.commands > user.commands.txt
#rm -f /tmp/user.commands
#uniq -c user.commands.txt > counted.commands
#sort -n -o counted.commands < counted.commands
#tail -50 counted.commands
