#!/bin/sh

# verbose(-ish);
Q=true;
if [ "$1" = "false" ]; then
  Q=false;
fi;

# what tools we use and where everything is 
B="SSFWROOT/PREFIX_tools-dir/FILEPRE_block-ipv4-addr.sh";
D="SSFWROOT/PREFIX_block-dir/ipv4";
L="SSFWROOT/PREFIX_log-dir/monitor-ipv4.sshd";
P="SSFWROOT/PREFIX_log-dir/monitor-ipv4.kex.pid";
if [ ! -f "$L" ]; then
  touch "$L";
#  touch "$P";
  chown WWWUSER "$L" "$P";
fi;

# startup;
#echo "$$" > "$P";
#echo "$(date -Iseconds)#$$#0#kex#started $(test "$Q" = "false" && echo quietly)" >> "$L";

# main loop;
for xLOG in $(ls -1 /var/log/messages* | grep -v "\.gz"); do
  xPIDS=$(cat "$xLOG" | grep "kex_exchange" | cut -d \: -f 3 | cut -d \[ -f 2 | cut -d \] -f 1);
  for xPID in $xPIDS; do
    xADDR=$(grep "\[$xPID\]" $xLOG | grep "auth.info sshd" | cut -d \: -f 4 | grep -E -o "[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}" | uniq);
    if [ ! "$xADDR" = "" ]; then
      X=$(echo "$xADDR" | wc -c);
      Z=$(echo "$xADDR" | cut -d \. -f 4);
      if [ $X -lt 7 -o -z "$Z" ]; then
        $Q && echo "$$:kex: error $xADDR";
      else
        if [ ! -f "$D/$xADDR" ]; then
          echo -n "$(date -Iseconds)#$$#0#kex#" >> "$L";
          $B "$xADDR" false >> "$L";
          $Q && echo "$$:kex: added $xADDR";
        fi;
      fi;
    fi;
  done;
done;

