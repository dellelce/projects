#
# code lite
#
# 140310 adding support for loading project scripts (_pautoload)
# 300310 adding support basic "skel" of directories
# 070410 adding basic support for phelp
#

export SRCCONFIG="$HOME/.src"
export SAVEDIRS="${SRCCONFIG}/savedirs"

unset PHELP_IDX

# 221012 added SRC variable
export SRC="$HOME/src"

#
# __phelp_idx
#
# adds an entry in the help index
#
# internal use only
#
__phelp_idx()
{
 [ -z "$1" ] && return 1

 export PHELP_IDX="$PHELP_IDX $1"
}

#
# __pautoload
# created: 042010
#
__pautoload()
{
 typeset topdir="${1}"
 [ ! -d "${topdir}" ] && return 1

 typeset autodir="$topdir/.autoload.d"

 typeset autofile="${topdir}/.autoload"
 [ -s "${autofile}" ] && { . "${autofile}" $*; }

 # Use AUTODIR for custom autoload directory
 [ ! -z "$AUTODIR" ] && { typeset autodir="$topdir/$AUTODIR"; }

 typeset file=""
 [ -d "${autodir}" ] && { for file in $autodir/*.sh; do [ -s "${file}" ] && . $file $*; done; }

 typeset welcomedir="$topdir/.welcome.d"
 [ ! -d "${welcomedir}" ] && return 0
 for file in $welcomedir/*.sh; do [ -s "${file}" ] && . $file $*; done
}

#
# psave: save current direct as a "project"
#
  __phelp_idx psave

psave()
{
  typeset _ppath="${PWD}"
  typeset _pname="${1}"
  typeset _pext="proj"

  [ ! -d "${SAVEDIRS}" ] && { echo "Save directory is invalid!"; return 1; }
  [ -z "${_pname}" ] && { echo "Project name is missing!"; return 1; }

  _pname="$(echo $_pname | tr ' ' '_')"

  typeset _fpname="${SAVEDIRS}/${_pname}.${_pext}"

  [ -s "${_fpname}" ] && { echo "Project already exists: ${_fpname}"; return 1; }

cat > "${_fpname}" << EOF
#
#
saved_time="$(date +%H%M)"
saved_date="$(date +%d%m%Y)"
fullpath="${_ppath}"
pname="${_pname}"
ptype="project"
EOF

  return $?
}

#
# pclass
#
# Created: 130910
#
# Create a new "project class" based on current directory
#
  __phelp_idx pclass

pclass()
{
  typeset _ppath="${PWD}"
  typeset _pname="${1}"
  typeset _pext="proj"

  [ ! -d "${SAVEDIRS}" ] && { echo "Save directory is invalid!"; return 1; }
  [ -z "${_pname}" ] && { echo "Class name is missing!"; return 1; }

  _pname="$(echo $_pname | tr ' ' '_')"

  typeset _fpname="${SAVEDIRS}/${_pname}.${_pext}"

  [ -s "${_fpname}" ] && { echo "Class already exists: ${_fpname}"; return 1; }

cat > "${_fpname}" << EOF
#
#
saved_time="$(date +%H%M)"
saved_date="$(date +%d%m%Y)"
fullpath="${_ppath}"
pname="${_pname}"
ptype="class"
EOF

  return $?
}

#
# pload
#
# created: 2010
#
  __phelp_idx pload

pload()
{
  typeset _pname="${1}"
  typeset _pext="proj"
  typeset _cwd="${PWD}"
  typeset fullpath

  [ ! -d "${SAVEDIRS}" ] && { echo "Save directory is invalid!"; return 1; }
  [ -z "${_pname}" ] && { echo "Project name is missing!"; return 1; }
  shift

  _pname="$(echo $_pname | tr ' ' '_')"

  typeset _fpname="${SAVEDIRS}/${_pname}.${_pext}"

  [ ! -s "${_fpname}" ] && { echo "Project does not exist: ${_fpname}"; return 1; }

  . "${_fpname}"

  # following two lines added 101010
  [ "${ptype}" = "class" ] && { cd "${_cwd}"; }
  [ "${ptype}" != "class" ] && { PROJECT="${_pname}"; }

  # 1635 151010 - load parent class
  [ ! -z "${pclass}" ] && { typeset _p="$pclass"; unset pclass; pload "${_p}"; unset _p; }

  [ -z "${fullpath}" ] && { echo "fullpath not set!"; return 1; }
  [ ! -d "${fullpath}" ] && { echo "fullpath is not valid!"; return 1; }

  # 070316: if not a class save directory in PROJECT_HOME
  [ "${ptype}" != "class" ] && { export PROJECT_HOME="${fullpath}"; }

#  echo "WARNING: should keep original directory if ptype = class" commented: 1704 101010
  cd "${fullpath}"
  __pautoload "${fullpath}" $*

  # 1504 200610 - we don't want the following variables to stay
  unset saved_date
  unset saved_time
  unset ptype
#  unset fullpath	# unset added: 181010

  # save last project call
  penv lastproject="$1"

  ## eof()
}

# preload: reload current project: useful if configuaration changed
#
preload()
{
 [ -z "$PROJECT" ] && { echo "PROJECT is not set! is any project loaded?"; return 1; }

 pload $PROJECT
 return $?
}

#
# pdel: remove project definition
#
  __phelp_idx pdel

pdel()
{
  typeset _pname="${1}"
  typeset _pext="proj"

  [ ! -d "${SAVEDIRS}" ] && { echo "Save directory is invalid!"; return 1; }
  [ -z "${_pname}" ] && { echo "Project name is missing!"; return 1; }

  _pname="$(echo $_pname | tr ' ' '_')"

  typeset _fpname="${SAVEDIRS}/${_pname}.${_pext}"

  [ ! -s "${_fpname}" ] && { echo "Project does not exist: ${_fpname}"; return 1; }

  echo "Project file for ${_pname} is ${_fpname}"

  rm "${_fpname}" &&
  {
    echo "File successfully removed"
  } ||
  {
    echo "Failed to remove file"
  }

  ## eof()
}

#
# plist: list all projects in a tabular format
#
  __phelp_idx plist

plist()
{
 # do it
 typeset _pext="proj"
 typeset _urgfile=".URGENT"
 typeset ldesc
 typeset pname

 [ ! -d "${SAVEDIRS}" ] && { echo "Save directory is invalid!"; return 1; }

 typeset item
 typeset lista="${SAVEDIRS}/*.${_pext}"

 for item in $lista
 do
   [ ! -f "$item" ] && continue
   . $item

   typeset _siz="${#pname}"
   typeset _maxsiz=24
   typeset _blanks=0
   typeset _blstr=""
   typeset _sep=" "

   let _blanks="(( $_maxsiz - $_siz ))"

   while [ $_blanks -ne 0 ]
   do
     _blstr="${_blstr} "
     let _blanks="(( $_blanks - 1 ))"
     [ "$_blanks" -lt 0 ] && { echo "_maxsiz = " $_maxsiz " _siz = " $_siz; return 1; }
   done

   [ -f "${fullpath}/${_urgfile}" ] && { _sep="[1m*[0m"; }

   [ "${ptype}" = "class" ] &&
   {
     typeset ldesc="[33m${fullpath}[0m"
   } ||
   {
     typeset ldesc="${fullpath}"
   }

   echo "${pname}${_blstr} ${saved_time} ${saved_date} ${_sep} ${ldesc}"
   unset ptype
   unset ldesc
#fixed: 181010 : variables staed after end of plist
   unset pclass
   unset fullpath
   unset saved_date
   unset saved_time
 done
}

#
# phelp: basic help
#
phelp()
{
 [ -z "${PHELP_IDX}" ] &&
  {
    echo "PHelp support not installed."
    return 1;
  }

 typeset item

 echo

 for item in $PHELP_IDX
 do
   echo "   $item"
 done

 echo
}

#
# pinfo: reports information on requested project
#
# created: 200610
#
  __phelp_idx pinfo

pinfo()
{
  typeset _pname="${1}"
  typeset fullpath=""
  typeset saved_date=""
  typeset saved_time=""
  typeset pname=""

  [ -z "$_pname" ] && _pname="$pname"
  [ -z "$_pname" ] && { echo "pinfo project_name"; return 1; }

  typeset _pext="proj"

  [ ! -d "${SAVEDIRS}" ] && { echo "Save directory is invalid!"; return 1; }

  [ -z "${_pname}" ] &&
   {
     echo "Project name is missing!"
     return 1
   }

  _pname="$(echo $_pname | tr ' ' '_')"

  typeset _fpname="${SAVEDIRS}/${_pname}.${_pext}"
  [ ! -s "${_fpname}" ] && { echo "Project does not exist: ${_fpname}"; return 1; }

  unset fullpath

  . "${_fpname}"

cat << EOF
fullpath:    ${fullpath}
saved_date:  ${saved_date}
saved_time:  ${saved_time}
ptype:       ${ptype:-project}
EOF

#  unset fullpath
#  unset saved_date
#  unset saved_time

# readded: 181010
  unset saved_date
  unset saved_time
  unset ptype
#  unset fullpath
  ## eof
}

#
# pdir
#
  __phelp_idx pdir

pdir()
{
  typeset _pname="${1}"
  typeset fullpath=""
  typeset saved_date=""
  typeset saved_time=""
  typeset pname=""

  [ -z "$_pname" ] && _pname="$pname"
  [ -z "$_pname" ] && { echo "pdir project_name"; return 1; }

  typeset _pext="proj"

  [ ! -d "${SAVEDIRS}" ] && { echo "Save directory is invalid!"; return 1; }

  [ -z "${_pname}" ] &&
   {
     echo "Project name is missing!"
     return 1
   }

  _pname="$(echo $_pname | tr ' ' '_')"

  typeset _fpname="${SAVEDIRS}/${_pname}.${_pext}"
  [ ! -s "${_fpname}" ] && { echo "Project does not exist: ${_fpname}"; return 1; }

  unset fullpath

  . "${_fpname}"

cat << EOF
${fullpath}
EOF

  unset saved_date
  unset saved_time
  unset ptype
#  unset fullpath

  ## eof
}

#
# pedit: open project definition in an editor
#
# Added: 1318 181010
  __phelp_idx pedit

pedit()
{
  typeset _pname="${1}"
  typeset _pext="proj"
  typeset rc=0

  [ ! -d "${SAVEDIRS}" ] && { echo "Save directory is invalid!"; return 1; }
  [ -z "${_pname}" ] && { echo "Project name is missing!"; return 1; }

  _pname="$(echo $_pname | tr ' ' '_')"
  typeset _fpname="${SAVEDIRS}/${_pname}.${_pext}"

  [ ! -s "${_fpname}" ] && { echo "File invalid"; return 1; }
  [ -z "$EDITOR" ] && { vim "${_fpname}"; rc=$?; } || { $EDITOR "${_fpname}"; rc=$?; }

  return $rc
}

# penv
#
# added: 071110
#
  __phelp_idx penv

penv()
{
  [ ! -d "${SRCCONFIG}" ] && { echo "SRCCONFIG not set"; return 1; }

  typeset _del=""
  [ "$1" == "-d" ] && { typeset _del=1; shift; }
  typeset _args="$*"
  typeset _edir="${SRCCONFIG}/env"
  typeset _awk="${SRCCONFIG}/scripts/awk/penv.awk"

  [ ! -d "${_edir}" ] && { echo "Invalid penv directory"; return 1; }
  [ ! -s "${_awk}" ] && { echo "codefile is invalid"; return 1; }
  [ -z "$_args" ] && { penvlist; return $?; }

  eval $(
  echo "$*" | awk               \
     -v del="${_del}"           \
     -v envdir="${_edir}"       \
     -f "${_awk}"
  )

}

#
# penvlist
#
  __phelp_idx penvlist

penvlist()
{
  typeset _edir="${SRCCONFIG}/env"
  typeset _postfix="env.txt"

  [ ! -d "${_edir}" ] && { echo "penvlist: no environment persistence directory"; return 1; }

  typeset item bitem

  for item in $_edir/*
  do
    [ ! -s "$item" ] && continue;
    bitem=$(basename $item)
    echo "${bitem%.${_postfix}}         $(< $item)"
  done
}

## EOF ##
