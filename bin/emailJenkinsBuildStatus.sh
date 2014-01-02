#! /bin/bash

if [ $# -ne 7 ]; then
  echo ""
  echo "Wrong number of arguments. Read the source, Luke."
  echo "Example usage: $0 run_unit_tests ci-action-capture https://ci.example.com/jenkins/rssAll some.dude@example.com jenkins.monitor@example.com 'Jenkins Monitor' mail.server.example.com"
  echo ""
  exit 1;
fi

DIR=`dirname $0`
PHASE="$1"
PROJECT="$2"
RSS_URL="$3"
RECIPIENTS="$4"
FROM="$5"
FROMNAME="$6"
SERVER="$7"

if [ ! -f "$HOME/.netrc" ]; then
  echo "Please put your credentials for Jenkins in $HOME/.netrc."
  exit 1
fi

RESULT="`$DIR/getJenkinsBuildStatus.sh \"$PHASE\" \"$PROJECT\" \"$RSS_URL\"`"
if [ $? -ne 0 ]; then
  echo "getJenkinsBuildStatus.sh returned an error. Bailing."
  exit 1
fi
STATUS=$(echo "$RESULT" | cut -f 1)
LINK=$(echo "$RESULT" | cut -f 2)

LINKFILE="$DIR/jenkins.${PHASE}.${PROJECT}.lastlink"
NEWLINKFILE="${LINKFILE}.new"

# The LINKFILE will exist if the previous status was broken.
# The set of status below needs to be the same as at the bottom of the file when be delete $LINKFILE.
# It needs to be the exhaustive set of non-broken statuses.
if [ "stable" == "$STATUS" -o "back to normal" == "$STATUS" ] &&  [ ! -f "$LINKFILE" ]; then
  echo "The build's status is '$STATUS' and $LINKFILE doesn't exist. Nothing to see here. `date`"
  exit 0
fi


# Dump the new link to a file for easy diffing. If the previous status was stable, there probably isn't a link file so diff will return 2.
echo "$LINK" > "$NEWLINKFILE"
diff --brief "$LINKFILE" "$NEWLINKFILE"

# Did diff say the files differed?
if [ $? -ne 0 ]; then
  mv "$NEWLINKFILE" "$LINKFILE"
  echo "need to email"
  PLAIN_CONSOLE_OUTPUT_URL="${LINK}consoleText"
  echo "PLAIN_CONSOLE_OUTPUT_URL=$PLAIN_CONSOLE_OUTPUT_URL"
  # Use an absolute path for curl in the new shell in case it doesn't inherit the right PATH.
  CURL_PATH=`which curl`
  CONSOLE_FETCH_CMD="$CURL_PATH -v --insecure --netrc \"$PLAIN_CONSOLE_OUTPUT_URL\""
  echo "Running CONSOLE_FETCH_CMD=$CONSOLE_FETCH_CMD"
  # Run it in a new shell because curl is wigging out about libcurl not supporting https otherwise. Completely insane, but works.
  CONSOLE_OUTPUT=$(bash -c "$CONSOLE_FETCH_CMD")
  #echo "CONSOLE_OUTPUT=$CONSOLE_OUTPUT"
  echo "<html><body>Build status is <a href='$LINK'>$STATUS</a> on $PHASE $PROJECT.  Check the <a href='${LINK}console'>build output</a> for why.<pre>$CONSOLE_OUTPUT</pre></body></html>" | \
    $DIR/email -html -n "$FROMNAME" -f "$FROM" -s "Build status is $STATUS on $PHASE $PROJECT." -r "$SERVER" "$RECIPIENTS"
else
  rm "$NEWLINKFILE"
  echo "The build's URL ($LINK) hasn't changed since the last email was sent. I'm done here."
fi

if [ "stable" == "$STATUS" -o "back to normal" == "$STATUS" ]; then
  # Jenkins does this really nice thing with the status so that when the build
  # goes from broken to fixed, the status is "fixed", but when there's more
  # than one successful build in a row, then the status is "stable".  Well, we
  # never want an email on stable.  Except when we do.  I just realized that
  # because they have all the different repos jammed into a single project, its
  # status is confusing.  It goes from broken to stable directly if another
  # repo build successfully when ours was broken.
  #
  # So to figure out if the previous statas was stable, I delete the linkfile.  I.e. the link file should only exist if the previous status was broken.
  rm "$LINKFILE"
fi
