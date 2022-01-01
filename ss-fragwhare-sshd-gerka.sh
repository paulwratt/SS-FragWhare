#!/bin/sh
### SS:FragWhare (run as root)
### Super Simple (fake) Fire Wall
### (Whare is Maori for "house")
### - to verify everything is working:
### ./ss-fragwhare.sh > verify.ssfw
### - to start as a "service", use:
### ./ss-fragwhare.sh false &

# default interval & increment, in seconds
I=1;

# maximum time between checks, in seconds
M=10;

# default fails before blocking an IP address
K=4;

# easier option to change "tail lines"
# default for tail is 10, dont go above 20
N=10

# where to record the Process ID
#echo "$$" > "ss-fragwhare.pid";

# verbose(-ish);
Q=true;
if [ "$1" = "false" ]; then
  Q=false;
fi;

# main loop;
O=""; S=""; T=0;
while true; do
O="$S";
# we can use `uniq` here because its only 10 lines max
S=$(tail -n $N /var/log/messages | grep "auth.info sshd" | cut -d \: -f 4 | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | uniq);
if [ "$S" = "$O" ]; then
# relieve pressure if no change;
  T=$(expr $T + $I);
  if [ $T -gt $M ]; then
    T=$M;
# dont do other things here, as it will exponentially use more processor time
# this script will only consume about 0.16% of CPU on a single core system
# BusyBox will increase memory usage by 1.5MB x2 (1x for script, 1x for sleep)
  fi;
  $Q && echo "$$:ss-fragwhare: waiting: $T";
else
for xADDR in $S ; do
  # minimum length of an IPv4 address is 7 
  X=$(echo "$xADDR" | wc -c);
  # but input might be broken, so double check
  Z=$(echo "$IP" | cut -d \. -f 4);
  if [ $X -lt 7 -o -z "$Z"]; then
    $Q && echo "$$:ss-fragwhare: ..hmm.. '$xADDR'"; 
  else
    # make sure this is th correct name for your system
    C=$(grep "$xADDR" /var/log/messages | wc -l);
    if [ $C -gt $K ]; then
      # silence "wrong input"
      ip route add blackhole $T/32 2>/dev/null;
      $Q && echo "$$:ss-fragwhare: added $xADDR";
    fi;
  fi;
done;
  T=$I;
fi;
sleep $T;
done;

### - to work across reboots:
### ip route show | grep blackhole > blackhole.ssfw
### cat blackhole.ssfw | xargs -n 1 -I {} ip route add {}/32
### - after 400-500 IPv4 are blocked, SSHd will be "quiet"
