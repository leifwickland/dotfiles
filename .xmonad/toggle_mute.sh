#!/bin/bash

CURRENT_STATE=`amixer get Master | egrep 'Playback.*?\[o' | egrep -o '\[o.+\]'`

if [[ "$CURRENT_STATE" == '[on]' ]]; then
  amixer set Master mute
else
  # The default unmute behavior results in the main being unmuted, but PCM staying muted, which is confusing.
  amixer set Master unmute
  amixer set PCM unmute
  amixer set Headphone unmute
fi
