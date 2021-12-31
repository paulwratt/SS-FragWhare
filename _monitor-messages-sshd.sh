#!/bin/sh

# default interval & increment, in seconds;
I=1;

# maximum time between checks, in seconds;
M=10;
#M=5;

# default fails before blocking an IP address;
#K=4;
K=1;

# what tools we use and where everything is 
B="SSFWROOT/PREFIX_tools-dir/FILEPRE_block-ipv4-addr.sh";
R="SSFWROOT/PREFIX_tools-dir/FILEPRE_block-ipv4-redo.sh";
D="SSFWROOT/PREFIX_block-dir/ipv4";
L="SSFWROOT/PREFIX_log-dir/monitor-ipv4.sshd";
P="$L.pid";
if [ ! -f "$L" ]; then
  touch "$L";
  touch "$P";
  chown WWWUSER "$L" "$P";
fi;

# verbose(-ish);
Q=true;
if [ "$1" = "false" ]; then
  Q=false;
fi;

# startup;
echo "$$" > "$P";
echo "$(date -Iseconds)#$$#0#monitor#started $(test "$Q" = "false" && echo quietly) (I=$I;M=$M;K=$K)" >> "$L";

# main loop;
O=""; S=""; T=0;
while true; do
O="$S";
S=$(tail /var/log/messages | grep "auth.info sshd" | cut -d \: -f 4 | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | uniq);
if [ "$S" = "$O" ]; then
# relieve pressure if no change;
  T=$(expr $T + $I);
  if [ $T -gt $M ]; then
    T=$M;
# DONT USE: cpu usage will go up 50 to 100 percent
# (we use redo script every hour _after_ www user cron job blocks any IPv4)
# while we are waiting, add any missing IPv4
#   $R | xargs -n 1 -I {} echo "$(date -Iseconds)#redo#$T#"{} >> "$L";
  fi;
  $Q && echo "$$:monitor: waiting: $T";
else
for xADDR in $S ; do
  X=$(echo "$xADDR" | wc -c);
  if [ $X -lt 7 ]; then
    echo "$(date -Iseconds)#$$#$T#monitor#error: $xADDR" >> "$L";
    $Q && echo "$$:monitor: error $xADDR";
  elif [ ! -f "$D/$xADDR" ]; then
    C=$(grep "$xADDR" /var/log/messages | wc -l);
    if [ $C -gt $K ]; then
      echo -n "$(date -Iseconds)#$$#$T#monitor#" >> "$L";
      $B "$xADDR" false >> "$L";
      $Q && echo "$$:monitor: added $xADDR";
    fi;
  fi;
done;
  T=$I;
fi;
sleep $T;
done;

