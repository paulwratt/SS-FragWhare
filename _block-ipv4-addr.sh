#!/bin/sh
# quite-ish
E=true;
if [ "$2" = "false" ]; then
  E=false;
fi;

IP=$(basename "$1");
if [ "$IP" = "" ]; then
  echo "$0 127.0.0.255";
  exit;
fi;

C=$(echo "$IP" | wc -c);
D=$(echo "$IP" | cut -d \. -f 4);
if [ $C -lt 7 -o -z "$D" ]; then
  echo "error: not IPv4: $IP";
  exit;
fi;

# IPv4 as files in directory
D="SSFWROOT/PREFIX_block-dir/ipv4";
if [ ! -d "$D" ]; then
  echo "not found: $D";
  exit;
fi;

cd "$D";
if [ "$(ls -1 2>/dev/null | grep $IP)" = "" ]; then
  echo "$(date -Iseconds)" > $IP;
  chown WWWUSER $IP;
else
  B=$(cat $IP);
  if [ "$B" = "" ]; then
    echo "$(date -Iseconds)" > $IP;
  else
    $E && echo "$IP already set: $(echo $B | tr T \ )";
  fi;
fi;

B=$(ip route show | grep " $IP ");
if [ "$B" = "" ]; then
  ip route add blackhole $IP/32;
  C="added";
  B=$(ip route show | grep " $IP ");
else
  C="exists";
fi;
echo "$C: $B";
$E && echo "show all: ip route show";

exit;

