#!/bin/bash

for i in ca mw gb ; do
  echo -n "$i: "
  curl "http://vipacs${i}01.rightnowtech.com/version"
  echo "" 
done
