#!/bin/sh

CONFIG_DEFAULT="$(dirname $0)/timetrack.conf.default"
CONFIG_SYSTEM="/etc/timetrack.conf"
CONFIG_LOCAL="$HOME/.timetrack"

fail() {
  echo "Error: $*" >&2
  exit 1
}

usage() {
  cat << EOF
Usage: $(basename $0) [-h|--help] [-t|--test] [-c|--config CONFIG]
EOF
  exit 3
}

parse_options() {
  OPTS=$( getopt -o ht --long help,test -n $(basename $0) -- "$@" )
  if [ $? != 0 ] ; then fail "Terminating..."; fi

  set -- $OPTS
  while [ ! -z "$1" ]; do
    case "$1" in
      -h|--help) usage ; shift ;;
      -t|--test) test_setup  ; exit ;;
             --) shift ; break ;;
    -c|--config) CONFIG_OVERRIDE=$2 ; shift 2 ;;
      *) fail "Unknown option: $1"
    esac
  done
}

load_configs() {
  [ -r "$CONFIG_DEFAULT" ]  && . "$CONFIG_DEFAULT"
  [ -r "$CONFIG_SYSTEM" ]   && . "$CONFIG_SYSTEM"
  [ -r "$CONFIG_LOCAL" ]    && . "$CONFIG_LOCAL"
  [ -r "$CONFIG_OVERRIDE" ] && . "$CONFIG_OVERRIDE"
}

set_defaults() {
  [ -z "$PATH" ]    && PATH=/usr/bin:/bin
  PATH=/usr/local/bin:$PATH
  [ -z "$MESSAGE" ] && MESSAGE="Please check in to timetrack"
  BASEPATH="$( dirname $( readlink -f $0 2> /dev/null ) 2> /dev/null )"
  [ -z "$BASEPATH" ] && BASEPATH="$( dirname $0 )"
  [ -z "$ICON" ]    && ICON="$BASEPATH/timetrack.png"
}

check_vars() {
  [ -z "$TIMETRACK_SERVER" ] && fail "TIMETRACK_SERVER not defined"
  [ -z "$AUTH_TOKEN" ]       && fail "AUTH_TOKEN not defined"
  [ -z "$DISPLAY" ]          && fail "DISPLAY not defined"
}

check_command() {
  [ -z "$1" ] && fail "Usage: check_command() COMMAND"
  which "$1" > /dev/null || fail "$1 not found"
}

check_growl() {
  ps -ef | grep -v grep | grep Growll \
    || open -b com.Growl.GrowlHelperApp 2> /dev/null \
    || fail "Growl is not installed"
}

test_setup() {
  ARCH="$(uname)"

  case "$ARCH" in
    Linux)
       check_command curl
       check_command notify-send
       ;;
    Darwin) 
       check_command growlnotify
       check_growl
       ;;
    *) fail "Unknown architecture: $ARCH"
  esac
}

check_timetrack_status() {
  curl -sf "${TIMETRACK_SERVER}/status.txt?auth_token=${AUTH_TOKEN}" | grep -q "away"
}

notify_user() {
  case "$(uname)" in
    Linux)
      DISPLAY=$DISPLAY notify-send -i "${ICON}" $NOTIFY_OPTIONS "${MESSAGE}" ;;
    Darwin)
      growlnotify --image "${ICON}" -m "${MESSAGE}" $GROWL_OPTIONS
      ;;
    *) fail "Unknown architecture"
  esac
}

parse_options "$@"
load_configs
set_defaults
test_setup
check_vars

check_timetrack_status && notify_user
