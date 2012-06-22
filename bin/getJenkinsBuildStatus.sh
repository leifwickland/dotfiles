#! /bin/bash

if [ $# -ne 3 ]; then 
  echo ""
  echo "Wrong number of arguments. Read the source, Luke."
  echo "Example usage: $0 run_unit_tests ci-action-capture https://ci.example.com/jenkins/rssAll"
  echo ""
  exit 1;
fi
DIR=`dirname $0`
PHASE="$1"
PROJECT="$2"
RSS_URL="$3"


if [ ! -f "$HOME/.netrc" ]; then
  echo "Please put your credentials for Jenkins in $HOME/.netrc."
  exit 1
fi

/nfs/local/linux/bin/curl -s --insecure --netrc "$RSS_URL" | sed -re 's@<title>|</entry>@\n@g' | grep -m 1 "^$PHASE $PROJECT" | sed -re "s@^$PHASE $PROJECT.* [(]([^)]+)[)]@\1@" -e 's@</title>@@' -e 's@<link type="[^"]*" href="([^"]*)".*@\t\1@'
