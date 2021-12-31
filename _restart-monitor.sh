#!/bin/sh

S="SSFWROOT/PREFIX_tools-dir";

# list valid "services"
if [ "$1" = "" -o "$2" = "" ]; then
  for X in $(ls -1 *_monitor-*.sh 2>/dev/null); do
    echo "$X" | cut -d \_ -f 2 | cut -d \. -f 1 | tr \- \ | sed 's/monitor//g';
  done;
  echo "$0 <log> <for>";
  echo "eg: $0 messages sshd";
  exit;
fi;

# Log directory
L="SSFWROOT/PREFIX_log-dir";
F="no-match";

# can make these generic or custom
if [ "$1" = "messages" -a "$2" = "sshd" ]; then
  F="monitor-ipv4.$2.pid";
  P=$(cat "$L/$F" 2>/dev/null);
fi;

# kill "service" if its already running
if [ -f "$L/$F" -a -n "$P" ]; then
  # make sure its actuallly _our_ "service"
  echo -n "killed: ";
  ps ax | grep $P | grep "FILEPRE_monitor-$1-$2.sh" && kill -9 $P;
  rm -f $L/$F;
fi;

# check for valid "service"
if [ ! -x "FILEPRE_monitor-$1-$2.sh" ]; then
  echo "error: not found: FILEPRE_monitor-$1-$2.sh";
  exit;
fi;

# start as background "service"
nohup ./FILEPRE_monitor-$1-$2.sh false 2>/dev/null 2>/dev/null &

# show how to get PID
echo "PID=cat $L/$F";
exit;

