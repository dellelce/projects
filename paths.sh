#
# File:         paths.sh
# Created:      280619 (originally) 230223 new version
# Description:  setup paths
#

### FUNCTIONS ###

loadvenv()
{
 typeset venv="$1"

 [ ! -z "$VIRTUALENV" -a "$VIRTUALENV" == "$venv" ] && return 0 # already activated
 [ ! -z "$VIRTUALENV" ] && { deactivate; } # deactivate before so we have a better "environment"

 . $venv/bin/activate
 return $?
}

### ENV ###

 [ -d "$PWD/py" ] && { export PYTHONPATH="$PWD/py"; }

 for dir in "$PWD/sh" "$PWD/bin"
 do
   [ -d "$dir" -a $(echo "$PATH" | grep -c "$dir") -eq 0 ] && { export PATH="$dir:$PATH"; }
 done

 for dir in *-env
 do
   # load only the first....
   [ -d "$dir" -a -s "$dir/bin/activate" ] && { loadvenv "$dir"; break; }
 done

 unset dir

### EOF ###
