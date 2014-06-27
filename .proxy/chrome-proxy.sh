#!/bin/bash

list() {
  ps aux | grep 'google.[c]hrome'
}
chromes=$(list| wc -l)
if [ "$chromes" -gt 2 ] ; then
  list
  echo "Chrome is already running."
  echo "Kill it and try again."
  exit -1
fi
nohup google-chrome --proxy-server=10.140.112.12:3128 & 
