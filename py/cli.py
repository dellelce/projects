"""Command Line Interface to "projects" class."""

from os.path import isdir


def info(pdb, name):
    """Return details specified projects.

    Original shell format:

    echo "${pname}${_blstr} ${saved_time} ${saved_date} ${_sep} ${ldesc}";

    example:

    woppy                    1921 14062019   /root/projects/woppy
    """
    proj = pdb.db[name]

    return "{name:24} {time} {date} {path} ".format(
        name=proj["pname"],
        time=proj["saved_time"],
        date=proj["saved_date"],
        path=proj["fullpath"],
    )


def pload(pdb, name):
    """Create shell instruction for "loading" a project."""
    pstr = []
    error = ""
    project = pdb.get(name)

    if not project:
        pstr.append(f'export ERROR="{name}: project does not exist."')
        pstr.append("echo $ERROR")
        return pstr

    fullpath = project["fullpath"]

    # print sanity test
    #   TODO
    if isdir(fullpath):
        pstr.append('export ERROR=""')
    else:
        pstr.append('export ERROR="{name}: {fullpath} does not exist."')
        pstr.append("echo $ERROR")
        return pstr

    # print cd command
    pstr.append(f"cd {fullpath}")

    # SHOULD? we implement class? never actually used
    # [ "${ptype}" = "class" ] && {
    #    cd "${_cwd}"
    # };
    # [ "${ptype}" != "class" ] && {
    pstr.append(f"export PROJECT={name}")
    # };
    # [ ! -z "${pclass}" ] && {
    #    typeset _p="$pclass";
    #    unset pclass;
    #    pload "${_p}";
    #    unset _p
    # };
    # [ -z "${fullpath}" ] && {
    #    echo "fullpath not set!";
    #    return 1
    # };
    # [ ! -d "${fullpath}" ] && {
    #    echo "fullpath is not valid!";
    #    return 1
    # };
    # cd "${fullpath}";

    # Load "autoload" -> thi is a shell thing, will stay as a shell function
    # __pautoload "${fullpath}" $*;
    pstr.append(f'__pautoload "{fullpath}"')

    # Update "penv" variable lastproject
    #   TODO
    # penv lastproject="$1"
    pstr.append(f'penv lastproject="{name}"')

    if error:
        pstr.append("echo $ERROR")

    return pstr


def pdel(pdb, name):
    """Remove entry from projects. Will not remove the base directory."""
    pstr = []
    project = pdb.get(name)

    if not project:
        pstr.append(f'export ERROR="{name}: project does not exist."')
        pstr.append("echo $ERROR")
        return pstr

    del pdb[name]
