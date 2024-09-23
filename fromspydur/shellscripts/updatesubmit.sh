updatesubmit()
{
    class="cs150"
    faculty="acharles"
    students=$(whoisin $class | tail -n +2 | sed 's/ .*$//') 
    for student in $students; do
        submit_dir="/home/$faculty/${class}_submissions"
        submit_cmd="function submit { command cp -p * $submit_dir/$student/. \; }"
        sudo -u $student -- sh -c "echo $submit_cmd >> /home/$student/.bashrc"
    done
}
