function conda
{
    if [ "$1" == "activate" ]; then 
        case $2 in
            "myang")
            export LD_LIBRARY_PATH="/usr/local/sw/anaconda/anaconda3/envs/qgis/lib"

            ;;

        esac
    fi

    conda $@
        
}
