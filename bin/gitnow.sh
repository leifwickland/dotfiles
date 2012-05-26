#! /bin/bash

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
  read -N1 i
  echo "I: '$i'"
  if [ "$i" != "y" ]; then 
    exit
  fi
  git rebase -i origin/master
fi

until [ "$(__isRebase)" -eq 0 ]; do
  git commit --amend  --date="`date +%s`" --message="`git show | grep '^    ' | sed 's/^    //'`" || exit
  git rebase --continue || exit
done

#
