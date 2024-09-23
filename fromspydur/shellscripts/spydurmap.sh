function spydur-map
{
    old_python_path="$PYTHONPATH"
    export PYTHONPATH=/usr/local/sw/hpclib
    command pushd /usr/local/sw/metabatch >/dev/null 
    python mapper.py
    command popd >/dev/null
    export PYTHONPATH="$old_python_path"
}
