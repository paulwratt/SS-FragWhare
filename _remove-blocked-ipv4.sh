#!/bin/sh

### Remove IPv4 via `ip`

B=$(basename $1);
if [ "$B" = "" ]; then
  echo "$0 127.0.0.254";
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

