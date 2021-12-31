#!/bin/sh

### Process IPv4 as files in directory

# working directory;
cd "SSFWROOT/PREFIX_tools-dir";

# default IPv4 directory;
D="../PREFIX_stats-dir/sshd";

# default count be fore blocking (4 is brutal);
xC=39;

# override and set defaults with command line arguments;
C=$1;
L="$2";
if [ "$C" = "" ]; then
  C=$xC;
fi;
if [ $C -eq $C ] 2>/dev/null; then
  true;
else
  C=$xC;
  L="$1";
fi;

# create and verify default directory
if [ "$L" = "" -a ! -d "$D" ]; then
  ./PREFIX_process-messages-sshd.sh;
  if [ ! -d "$D" ]; then
    echo "error: failed: process-messages-sshd";
    exit;
  fi;
fi;

if [ "$L" = "" ]; then
  L="$D";
else
  if [ ! -d "$L" ]; then 
    echo "$0 4 ../PREFIX_archive-dir/2021-07\\=July_2021/sshd/";
    exit;
  fi;
fi;

for xADDR in $(ls -1 $L/ 2>/dev/null); do
  if [ $(cat $xADDR) -gt $C ]; then
    ./PREFIX_block-ipv4-addr.sh $xADDR false;
  fi;
done;

echo "ip route show | less";

exit;

