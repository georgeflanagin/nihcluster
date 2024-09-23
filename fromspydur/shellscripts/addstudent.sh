function addstudent
{
    # addstudent alina of milesdavis alias Alina
    if [ -z $3 ]; then
        echo "Syntax: addstudent {netid} of {faculty} class {class_dir_name} [alias alias-name]"
        echo "  Example: "
        echo " "
        echo "       addstudent ps9yy of gflanagi class cs150 alias Pat"
        echo " "
        echo "    creates a directory named ~gflanagi/cs150_submissions/Pat that"
        echo "    only ps9yy (Pat) can write to, and from which no one but gflanagi "
        echo "    can read." 
        echo " "
        echo "       add student sd6yy of gflanagi class cs323"
        echo " "
        echo "    creates a directory named ~gflanagi/cs323_submissions/sd6yy that"
        echo "    only sd6yy can write to, and from which no one but gflanagi can"
        echo "    read. With no alias name, the netid is used." 
        return
    fi

    # Set up our vars.
    student="$1"
    faculty="$3"
    class="$5"
    alias=${7-$student}

    # These are the directories we need.     
    submit_dir="/home/$faculty/${class}_submissions"
    readable_dir="/home/$faculty/${class}_readable"
    student_dir="$submit_dir/$alias"
    
    # Appropriate submit and obtain commands.
    submit_cmd="function submit { command cp -p * $submit_dir/$alias/. \; }"
    obtain_cmd="function obtain { command cp -p -r $readable_dir . \; }"

    # Create the directories with the -p option so that it will not 
    # cause an error if they already exist.

    # Only allow users to navigate to the submit_dir, nothing more.
    sudo -u $faculty mkdir -p $submit_dir
    sudo -u $faculty chmod 711 $submit_dir

    # Open up the readable dir.
    sudo -u $faculty mkdir -p $readable_dir
    sudo -u $faculty chmod 755 $readable_dir

    # Remove all outside access on the student's dir.
    sudo -u $faculty mkdir -p $student_dir
    sudo -u $faculty chmod 700 $student_dir

    # Create a loophole that lets the student write to this directory
    sudo -u $faculty setfacl -m $student:wx $student_dir 

    # If the alias name differs from the student's netid, create
    # a symbolic link with the netid as the name of the symlink.
    if [ $alias != $student ]; then
        sudo -u $faculty ln -s $student_dir $submit_dir/$student
    fi

    # As a test, create a file. 
    sudo -u $student -- sh -c "umask 022 && touch $student_dir/samplefile"
    if [ ! $? ]; then
        echo "$student unable to create sample file in $student_dir"
        return
    fi
    sudo -u $faculty -- sh -c "cat $student_dir/samplefile"
    if [ ! $? ]; then 
        echo "$faculty unable to read sample file in $student_dir"
        return
    fi 

    # append the following to the student's login.
    sudo -u $student -- sh -c "echo #### The following lines add the submit and obtain commands. #### >> /home/$student/.bashrc"
    sudo -u $student -- sh -c "echo $submit_cmd >> /home/$student/.bashrc"
    sudo -u $student -- sh -c "echo $obtain_cmd >> /home/$student/.bashrc"
    sudo -u $student -- sh -c "echo umask 022 >> /home/$student/.bashrc"
}

