#!/bin/bash

if [ $# -lt 1 ]; then 
  echo "USAGE:"
  echo "  $0 <path/to/unwanted/file> [path/to/more/unwanted/files]"
  echo ""
  echo "WARNING: DO NOT USE THIS ON PUBLISHED COMMITS."
  echo ""
  echo "The files in the last commit were:"
  git show --pretty="format:" --name-only 
  exit 0
fi;
LAST_COMMIT_MESSAGE="$(git log -1 --pretty=%B)"
git reset --soft HEAD^
if [ $? -ne 0 ]; then 
  echo "Undoing the previous commit failed. I'm stopping."
  exit -1
fi
git reset HEAD "$@"
if [ $? -ne 0 ]; then 
  echo "Removing previously committed files from the index failed. Sorry?"
  exit -1
fi
echo "The previous commit message was:"
echo "$LAST_COMMIT_MESSAGE"
echo ""
read -p "Would you like to commit the changes with the same message as last time? [Y/n]" response
if [ "$response" != "n" ]; then 
  git commit -m "$LAST_COMMIT_MESSAGE"
fi
