# git push with some extra nicities
gp()
{
 typeset rc=0
 typeset wd="$PWD"

 git pull && git push && git status || return $?

 # if working inside a project do run "pload" for that project.
 [ ! -z "$PROJECT" -a "${PWD#$PROJECT_HOME}" != "$PWD" -a $(type -t pload) == "function" ] &&
 {
   pload $PROJECT; rc=$?;
   cd "$wd"
   return $rc
 }
}

