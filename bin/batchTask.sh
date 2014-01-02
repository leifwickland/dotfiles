#!/bin/bash

if [ $# -ne 2 ]; then
  echo ""
  echo "Adds tasks to QA stories from a file."
  echo ""
  echo "Usage: $0 refno taskFile"
  echo ""
  echo "taskFile should contain lines like:"
  echo "  Description of a task that will take 4 hours  4"
  echo "  An easier task  2"
  echo "  All that matters is that there's whitespace before the number of hours 999"
  echo ""
  exit 0
fi

if [ ! -r "$2" ]; then
  echo "The task file ($2) wasn't readable."
  exit 1
fi

refno="$1"
taskFile="$2"

export children=()
echo "Adding tasks..."
while read line; do
  line=$line # Trim whitespace
  if [ -n "$line" ] ; then
    export message="$(echo "$line" | sed -nre 's/^[[:space:]]*(.*)[[:space:]]+[0-9]+[[:space:]]*$/\1/p')"
    export hours="$(echo "$line" | sed -nre 's/^.*[[:space:]]+([0-9]+)[[:space:]]*$/\1/p')"
    if [ -z "$message" -o -z "$hours" -o "$message" = "$hours" ]; then
      echo "ERROR!"
      echo "ERROR: I couldn't read message and hours from this line: '$line'";
      echo "ERROR!"
      exit 1
    fi
    qa -x "$refno" task "$message" $hours &
    child=$!
    children+=($child)
  fi
done < "$taskFile"
for child in "${children[@]}"; do
  wait $child
done
echo "Tasks added."
echo ""
echo "All tasks on $refno:"
qa -x "$refno" tasks | grep -vP '^ *(Assigned|Status):'
