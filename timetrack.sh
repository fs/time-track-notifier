#!/bin/sh -x

CONFIG_DEFAULT="$(dirname $0)/timetrack.conf.default"
CONFIG_SYSTEM="/etc/timetrack.conf"
CONFIG_LOCAL="$HOME/.timetrack"

fail() {
  echo "Error: $*"
  exit 1
}

usage() {
  cat << EOF
EOF
}

notify_user() {

  DISPLAY=$DISPLAY $NOTIFYSEND -i "${ICON}" $NOTIFY_OPTIONS "${MESSAGE}"
}

[ "$1" = "-h" -o "$1" = "--help" ] && usage

[ -r "$CONFIG_DEFAULT" ] && . "$CONFIG_DEFAULT"
[ -r "$CONFIG_SYSTEM" ] && . "$CONFIG_SYSTEM"
[ -r "$CONFIG_LOCAL" ]  && . "$CONFIG_LOCAL"

[ -z "$TIMETRACK_SERVER" ] && fail "TIMETRACK_SERVER not defined"
[ -z "$AUTH_TOKEN" ] && fail "AUTH_TOKEN not defined"
[ -z "$DISPLAY" ] && fail "DISPLAY not defined"

[ -z "$MESSAGE" ] && MESSAGE="Please check in to timetrack"
[ -z "$ICON" ] && ICON="$( dirname $( readlink -f $0 ) )/timetrack.png"

[ -z "$PATH" ] && PATH=/usr/bin:/bin

[ -z "$NOTIFYSEND" ] && NOTIFYSEND=$( which notify-send | grep -v 'not found' )
[ -z "$NOTIFYSEND" ] && fail "NOTIFYSEND not found. 'apt-get install libnotify-bin' is likely to help you"

curl -sf "${TIMETRACK_SERVER}/status.txt?auth_token=${AUTH_TOKEN}" | grep -q "away" && notify_user
