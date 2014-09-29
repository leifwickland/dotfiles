#! /bin/bash

if [ $# -ne 1 ]; then
  echo "USAGE: $0 <rebaseTo>"
  echo ""
  echo "Example: $0 origin/master   # If you're on master"
  echo "Example: $0 master          # If you're on a branch"
  echo ""
  exit -1
fi

# Changes the date to the current moment of all commits which have not been pushed to origin.

# Stolen from: http://repo.or.cz/w/git.git/blob/HEAD:/contrib/completion/git-completion.bash#l75
__gitdir()
{
  if [ -z "${1-}" ]; then
    if [ -n "${__git_dir-}" ]; then
      echo "$__git_dir"
    elif [ -d .git ]; then
      echo .git
    else
      git rev-parse --git-dir 2>/dev/null
    fi
  elif [ -d "$1/.git" ]; then
    echo "$1/.git"
  else
    echo "$1"
  fi
}

g="$(__gitdir)"
__isRebase() {
  if [ -f "$g/rebase-merge/interactive" ]; then
    echo 1
  else
    echo 0
  fi
}

if [ "$(__isRebase)" -eq 0 ]; then
  echo ""
  echo "You're not in a rebase."
  echo "If you want to update the time on all unpushed commits, an interactive rebase must be started."
  echo "To proceed, press 'y', then modify all the lines to begin with 'e' in the interactive editor."
  echo ""
  echo -n "Modify all unpushed commits to have the current time? (y/N) "
  read -n1 i
  echo "I: '$i'"
  if [ "$i" != "y" ]; then
    exit
  fi
  git rebase -i $1
fi

until [ "$(__isRebase)" -eq 0 ]; do
  COMMIT=`git show`
  if [ 1 -ne `echo "$COMMIT" | head -n 1 | grep ^commit | wc -l` ]; then
    echo "I couldn't figure out what the commit message is.  Abort the rebase!"
    exit
  fi
  COMMENT="`echo "$COMMIT" | tail -n +5 | sed -nre 's/^    (.*)/\1/p;/^$/q'`"
  git commit --amend  --date="`date +%s`" --message="$COMMENT" || exit
  git rebase --continue || exit
done

#
