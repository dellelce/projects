
# shell function wrappers for python-based code

export PYCLI=$PROJECTS/py/cli.py     # temporary path in project's python path 

# pinfo outputs information all
_pinfo() { $PYCLI info $*; }

# pload updates the environment with the output of $PYCLI load
_pload() { eval $($PYCLI load $* ); }

_psave() { $PYCLI save $*; }

# pclass  -> do not implement initially

_pdel() { $PYCLI delete $*; }

_plist() { $PYCLI list; }

_pdir() { $PYCLI dir $*; }

# pedit()  -> probably not implement

_penv() { $PYCLI env $*; } # pload uses penv to update "lastproject" also used to set login-time {project_name}_laswelcome

_penvlist() { $PYCLI envlist $*; }

__pautoload()
{
 typeset file=""
 typeset topdir="${1}"
 [ ! -d "${topdir}" ] && return 1

 typeset autofile="${topdir}/.autoload"
 [ -s "${autofile}" ] && { . "${autofile}" $*; }

 typeset autodir="$topdir/.autoload.d"
 # Use AUTODIR for custom autoload directory
 [ ! -z "$AUTODIR" ] && { typeset autodir="$topdir/$AUTODIR"; }

 [ -d "${autodir}" ] && { for file in $autodir/*.sh; do [ -s "${file}" ] && . $file $*; done; }

 typeset welcomedir="$topdir/.welcome.d"
 [ ! -d "${welcomedir}" ] && return 0
 for file in $welcomedir/*.sh; do [ -s "${file}" ] && . $file $*; done
}
