#!/bin/sh

if [ "$1" = "" ]; then
  echo "$0 [show|load]|[add|del _ipv4_/_mask_]";
  echo "eg: $0 add 192.241.128.0/17";
  exit;
fi;

L="../PREFIX_log-dir/monitor-ipv4.sshd"
B="../PREFIX_block-dir/ipv4/.ranges.ipv4";

if [ "$1" = "show" ]; then
  ip route show | grep / | grep blackhole;
  echo "$(ip route show | grep / | grep blackhole | wc -l) of $(cat $B | grep -v \# | wc -l) IPv4 ranges";
  exit;
fi;

if [ "$1" = "load" ]; then
  cat "$B" | grep -v \# | xargs -n 1 -I {} ip route add blackhole {};
  echo "$(date -Iseconds)#$$#0#range#loaded '$B'" >> "$L";
  exit;
fi;

IR="$1"
D="false";
if [ "$1" = "del" ]; then
  D="true";
  IR="$2";
fi;

if [ "$1" = "add" ]; then
  IR="$2";
fi;

IR=$(echo "$IR" | grep / );
if [ "$IR" = "" ]; then
  echo "error: range eg: 192.241.128.0/17";
  exit;
fi;

# get range mask part
M=$(basename "$IR");
if [ "$M" = "" ]; then
  echo "error: no range mask";
  exit;
fi;

# make sure range mask is a number
if [ $M -eq $M ]; then
  true;
else
  echo "error: NaN: range mask";
  exit;
fi;

# check for single IPv4 range mask
if [ $M -eq 32 ]; then
  echo "error: range mask for single IPv4 address";
  exit;
fi;

# check for valid range mask
if [ $M -lt 8 -o $M -gt 32 ]; then
  echo "error: wrong range mask";
  exit;
fi;

# get IPv4 part
I=$(dirname "$IR");
if [ "$I" = "$M" ]; then
  echo "error: nope";
  exit;
fi;

# make sure IPv4 has at least has 3 dots
X=$(echo "$I" | cut -d \. -f 4);
if [ "$X" = "" ]; then
  echo "error: not IPv4";
  exit;
fi;

# FIXME: /24 implies *.0 but smaller ranges might want to be blocked
R=$(echo "$I" | grep "\." | sed 's/.0//g' );
if [ "$R" = "" ]; then
  echo "error: not good IPv4 for range";
  exit;
fi;

logRecord()
{
if [ "$1" = "true" ]; then
  echo "$(date -Iseconds)#$$#0#range#removed: $IR" >> "$L";
else
  echo "$(date -Iseconds)#$$#0#range#added: $IR" >> "$L";
fi;
}

# more checks
X=$(cat "$B" | grep "^$IR");
Z=$(ip route show | grep " $IR");
if [ "$D" = "true" ]; then
  if [ "$X" = "" -a "$Z" = "" ]; then
    echo "error: remove: cant find range";
    exit;
  fi;
  if [ "$X" = "" ]; then
    echo "warning: range not already in '$B'";
  else
    sed -i $(cat "$B" | grep -n "$IR" | cut -d \: -f 1)d "$B";
  fi;
  if [ "$Z" = "" ]; then
    echo "warning: range wasn't already blocked";
  else
    ip route del blackhole "$IR";
  fi;
  echo "removed: range: $IR";
else
  if [ ! -z "$X" -a ! -z "$Z" ]; then
    echo "error: range is already blocked";
    exit
  fi
  if [ ! -z "$X" ]; then
    echo "warning: range is already in '$B'";
  else
    echo "$IR" >> "$B";
  fi;
  if [ ! -z "$Z" ]; then
    echo "warning: range was already blocked";
  else
    ip route add blackhole "$IR";
  fi;
  echo "added: range: $IR";
fi;

logRecord "$D" "$IR";

exit

