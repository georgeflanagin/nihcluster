function spydurview
{
    old="$PYTHONPATH"
    oldlib="$LD_LIBRARY_PATH"
    export PYTHONPATH="/usr/local/sw/hpclib"
    export LD_LIBRARY_PATH=
    python /home/installer/spydurview.george/spydurview.py
    export PYTHONPATH="$old"
    export LD_LIBRARY_PATH="$oldlib"
}
