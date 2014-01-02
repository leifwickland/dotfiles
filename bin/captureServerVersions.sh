#!/bin/bash

for i in ca mw gb ; do
  echo -n "$i: "
  response=$(curl -v "http://vipacs${i}01.rightnowtech.com/version" 2>&1)
  version="$(echo "$response" | tail -n 1)"
  server="$(echo "$response" | grep 'RNT-Machine' | sed 's/.*RNT-Machine: //')"
  echo "$version from server $server"
done
