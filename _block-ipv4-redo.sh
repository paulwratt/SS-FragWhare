#!/bin/sh

### Check & Reload IPv4 address via `ip`;

# working directoy;
cd "SSFWROOT/PREFIX_tools-dir";

# temp output file;
T="../txt";

# IPv4 block directory;
D="../PREFIX_block-dir/ipv4";

# (option) log file
L="../PREFIX_log-dir/monitor-ipv4.sshd";

# error debugging log;
E="../PREFIX_log-dir/redo-debug.ipv4";

# utility to use
B="./PREFIX_block-ipv4-addr.sh";

if [ "$1" = "--from-reboot" ]; then
  R="/var/log/blocked-at-reboot.ipv4";
  echo -n "" > $R;
  for xADDR in $(ls -1 $D/ 2>/dev/null); do
    $B $xADDR false >> $R;
  done;
  echo "$(date -Iseconds)#$$#0#boot#added: $(cat $R | wc -l)" >> $L;
  if [ "$2" = "--include-ranges" ]; then
    cat $D/.ranges.ipv4 | xargs -n 1 -I {} ./PREFIX_block-ipv4-range.sh {} >> $R.ranges
    echo "$(date -Iseconds)#$$#0#redo#added: $(grep "^added:" $R.ranges | wc -l) ranges at reboot" >> $L;
  fi
  exit;
fi;

#ip route show | grep blackhole | cut -d \  -f 2 > $T;
ip r | grep blackhole > $T;
for xADDR in $(ls -1 $D/ 2>/dev/null); do
  S=$(echo "$xADDR" | wc -c);
  if [ $S -lt 7 ]; then
    rm -f $D/$xADDR;
  else
    if [ $S -gt 15 ]; then
      X=$(echo "$xADDR" | sed 's/\(\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}\).\(\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}\)/\3/gp' | uniq);
      if [ -n "$D/$X" ]; then
        cp "$D/$xADDR" "$D/$X"
      fi;
      rm -f $D/$xADDR;
      xADDR="$X";
    fi;
    M=$(grep -m1 " $xADDR " $T);
    if [ -f "$L" ]; then
      if [ "$M" = "" ]; then
        echo -n "$(date -Iseconds)#$$#0#redo#" >> "$L";
#echo "$(date -Iseconds)#$$#$xADDR" >> "$E";
	$B "$xADDR" false >> "$L";
	echo "$$:redo: added $xADDR";
      fi;
    else
      test -z "$M" && $B $xADDR false;
    fi;
  fi;
done;
