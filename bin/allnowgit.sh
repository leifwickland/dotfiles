#!/bin/bash
die() {
  echo "$1" 1>&2
  exit 1
}
test "0" -eq "$(git add -n . | wc -l)" || die "Your tree is dirty. Please stash your changes and run this script again."
currentBranch() {
  git branch --no-color | grep '[*]' | sed 's/[ *]//g'
}
branch="$(currentBranch)"
remote=$(git config --local --get "branch.$branch.remote")
if [ -z "$remote" ]; then
  echo "I couldn't determine the current branch's ($branch) remote."
  exit 1
fi
delta="$remote/$branch..HEAD"
echo ""
echo "Changes which would have their data updated:"
echo ""
git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --topo-order --date=relative $delta
now=$(date +%s)
read -p "Do you want to update the commit time of all of the above changes to $(date)? [(y/N)]" response
if [ "$response" != "y" ]; then 
  echo "You didn't say the magic word. Exiting."
  exit 1
fi
seqEditor=/tmp/allnowgit.sh-seq-editor-$now-$RANDOM
echo 'if [ 0 -ne $(head -n1 $1 | grep "^noop" | wc -l) ]; then exit 1; else sed -i -re "s/^pick /e /" $1; fi' > $seqEditor
GIT_SEQUENCE_EDITOR="bash '$seqEditor'" git rebase -i
rebaseResult=$?
rm $seqEditor
test $rebaseResult -eq 0 || die "Git rebase failed. That usually means there was nothing to rebase."
while [ "$(currentBranch)" == "(nobranch)" ]; do 
  export GIT_COMMITTER_DATE=$now
  git commit --amend --date="$GIT_COMMITTER_DATE" -C HEAD || die "Updating the time failed!"
  git rebase --continue || die "Continuing the rebase failed!"
  let now="$now+1"
done
unset GIT_COMMITTER_DATE
