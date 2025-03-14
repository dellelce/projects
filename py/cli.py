#!/bin/env python

"""Command Line Interface to "projects" class."""

from os.path import isdir  # used to check if "fullpath" exists.


def info(pdb, args):
    """Return details specified projects.

    fullpath:    /home/antonio/projects/projects
    saved_date:  15112023
    saved_time:  0239
    ptype:       project

    note: currently not implementing ptype as "project classes" were never fully developed.

    """
    name = args[0]
    proj = pdb.db[name]

    return """
fullpath:   {path}
saved_date: {date}
saved_time: {time}
ptype:      project
""".format(
        time=proj["saved_time"],
        date=proj["saved_date"],
        path=proj["fullpath"],
    )


""" this was from plist not pinfo
    woppy                    1921 14062019   /root/projects/woppy
"""


def load(pdb, args) -> []:
    """
    Create shell instruction for "loading" a project.

    - Sanity tests
    - Load project definition
    - uncertain bit:   [ "${ptype}" = "class" ] && { cd "${_cwd}"; };
    - set PROJECT environment variable
    - [classes not implemented initially] if pclass is set should load it as a class
    - sanity checks on fullpath
    - write to stdout: "cd $fullpath"
    - set PROJECT_HOME environment variable [if not a class]
    - write to stdout: "__pautoload $fullpath"
    - update "lastproject" environment [How?]
    """

    name = args[0]
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
    if isdir(fullpath):
        pstr.append(f'export PROJECT_HOME="{fullpath}"')
        pstr.append(f'cd "{fullpath}"')

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


def delete(pdb, args):
    """Remove entry from projects. Will not remove the base directory."""
    name = args[0]
    project = pdb.get(name)

    if not project:
        print(f"{name} does not exist.")

    #del pdb[name]


def save(pdb, args) -> None:
    name = args[0]

    if pdb.get(name) is not None:
        print(f"project {name} already exists.")
    else:
        print(f"project does not exists but there is no code")


def hello(pdb, args) -> None:
    print(pdb)

    for arg in args:
        print(pdb[arg])


if __name__ == "__main__":
    from sys import argv
    from legacy import projects

    args = argv[1::]
    action_name = args[0]
    args.pop(0)

    action = globals().get(action_name, None)

    # load is a special case
    if action_name != "pload" and action is None:
        print(f"action {action_name} not defined.")
        exit(1)

    pdb = projects()

    if callable(action):
        output = action(pdb, args)

        if type(output) is list:
            print(";".join(output))
