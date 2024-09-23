can()
{
    if [ -z $2 ]; then
        echo "Usage: can {read|write|execute} {file-or-dir}"
        return
    fi

    case "$1" in 

        read|r)
            test -r "$2"
            result=$?
        ;;

        write|w)
            test -w "$2"
            result=$?
        ;;

        execute|x)
            test -x "$2"
            result=$?
        ;;

        *)
            echo "Unknown mode $1"
            return
        ;;
    esac

    if [[ $result == 0 ]]; then
        echo "yes"
    else
        echo "no"
    fi
}

