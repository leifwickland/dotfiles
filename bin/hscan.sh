#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 <tableName> [outputFile]"
  exit
fi
if [ $# -lt 2 ]; then
  OUT=$1
else
  OUT=$2
fi

# I guess this doesn't get set when bash executes a shell script...
COLUMNS=`stty size | cut -d ' ' -f 2`
OLDCOLS=$COLUMNS
stty cols 9999 
echo "scan '$1'" | hbase shell | sed -r -e 's/[ ]{2,}/ /g' -e 's/timestamp=[0-9]+/ts=X/' > $OUT 
stty cols $OLDCOLS
