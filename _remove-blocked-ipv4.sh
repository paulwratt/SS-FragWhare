#!/bin/sh

### Remove IPv4 via `ip`

B=$(basename $1 2>/dev/null);
if [ "$B" = "" ]; then
  echo "delete block IPv4 address or range"
  echo "usage: $0 127.0.0.254";
  exit;
fi;

if [ ! "$B" = "$1" -a "$(echo "$1" | grep / 2>/dev/null)" = "$1" ]; then
  FL="TRUE";
  L=$(grep -nm1 "^$1" ../b/ipv4/.ranges.ipv4 | cut -d \: -f 1);
  if [ "$L" = "" ]; then
    echo "warning: range not in blocklist";
    FL="FALSE";
  else
    sed -i "${L}d" ../b/ipv4/.ranges.ipv4 ;
    echo "range: deleted from blocklist";
  fi;
  FB="TRUE";
  B="$(ip r | grep / | grep -m1 "blackhole $1")";
  if [ "$B" = "" ]; then
    echo "warning: range not already blocked";
    FB="FALSE";
  else
    ip route del $1;
    echo "range: deleted from blackhole list";
  fi;
  if [ "$FL" = "FALSE" -a "$FB" = "FALSE" ]; then
    echo "error: range not found: $1";
  else
    echo "range: removed: $1";
  fi;
  exit;
fi;

C=$(echo "$B" | wc -c);
D=$(echo "$B" | cut -d \. -f 4);
if [ $C -lt 7 -o -z "$D" ]; then
  echo "error: not IPv4: $B";
  exit;
fi;

A=$(cat "SSFWROOT/PREFIX_block-dir/ipv4/$1" 2>/dev/null);
if [ "$A" = "" ]; then
  echo "not found: $B";
else
  echo "removed: $B ( added: $(echo $A | tr T \ ) )";
fi;
rm -f SSFWROOT/PREFIX_block-dir/ipv4/$B 2>/dev/null;
ip route del $B 2>/dev/null;

