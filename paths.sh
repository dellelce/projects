#
# File:         paths.sh
# Created:      280619 (originally) 230223 new version
# Description:  setup paths
#

## FUNCTIONS ##

loadvenv()
{
 typeset venv="$1"

 [ ! -z "$VIRTUALENV" -a "$VIRTUALENV" == "$venv" ] && return 0 # already activated
 [ ! -z "$VIRTUALENV" ] && { deactivate; } # deactivate before so we have a better "environment"

 . $venv/bin/activate
 return $?
}

findvenv()
{
 typeset dir

 for dir in *-env
 do
   # load only the first....
   [ -d "$dir" -a -s "$dir/bin/activate" ] && { loadvenv "$dir"; break; }
 done
}

safeaddpath()
{
  typeset dir

  for dir in $*
  do
   [ -d "$dir" -a $(echo "$PATH" | grep -c "$dir") -eq 0 ] && { export PATH="$dir:$PATH"; }
  done
}

pypath()
{
  typeset dir="$1"

  [ ! -d "$dir" ] && return 2; # sanity check

  # quick: if PYTHONPATH not set go easy
  [ -z "$PYTHONPATH" ] && { export PYTHONPATH="$dir"; return 0; }

  [ $(echo "$PYTHONPATH" | grep -c "$dir") -eq 0 ] && export PYTHONPATH="$PYTHONPATH:$dir"
}

## MAIN ##

 pypath "$PWD/py"
 safeaddpath "$PWD/sh" "$PWD/bin"
 findvenv

## EOF ##
