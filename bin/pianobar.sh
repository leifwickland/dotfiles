#!/bin/bash

die() {
  echo "$@" 1>&2
  exit 1
}

BINARY="$HOME/app/pianobar/pianobar"
[ -x "$BINARY" ] || die "Pianobar binary doesn't exist at $BINARY."

PASSWORD_FILE="$HOME/.config/pianobar/password" 
[ -r "$PASSWORD_FILE" ] || die  "You need to put your password in $PASSWORD_FILE"
 
CONFIG_FILE="$HOME/.config/pianobar/config" 
CONFIG_TEMPLATE="$HOME/.config/pianobar/config.template" 
[ -w "$CONFIG_TEMPLATE" ] || die  "I couldn't find your pianobar config template at $CONFIG_TEMPLATE"

PASSWORD=$(cat "$PASSWORD_FILE" | head -n 1 | sed 's/^ *//' | sed 's/ *$//')
PASSWORD_PLACEHOLDER="PASSWORD_PLACEHOLDER"
sed "s/$PASSWORD_PLACEHOLDER/$PASSWORD/" $CONFIG_TEMPLATE > $CONFIG_FILE || die "I couldn't update your $CONFIG_FILE with your password."

exec $BINARY
