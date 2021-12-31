#!/bin/sh
tStart=$(date +%s%N);
if [ ! -d "../PREFIX_log-dir" ]; then
  echo "not found: ../PREFIX_log-dir";
  exit;
fi

xSVC="sshd";
xLOG="../PREFIX_log-dir/messages.sshd";
M0="/var/log/messages.0"
if [ ! -d $M0 -a -d "/var/log/messages.1" ]; then
  M0="/var/log/messages.1"
fi
cat "$M0" | grep "$xSVC" | grep "Failed password" > "$xLOG";
cat "/var/log/messages" | grep "$xSVC" | grep "Failed password" >> "$xLOG";

mkdir -p "../PREFIX_stats-dir/$xSVC";
chown WWWUSER "../PREFIX_stats-dir/$xSVC";
rm -f ../PREFIX_stats-dir/$xSVC/*;
rm -f ../PREFIX_stats-dir/$xSVC.haxors;
rm -f ../PREFIX_stats-dir/$xSVC.fails;

cd "../PREFIX_stats-dir/$xSVC";
cat "../$xLOG" | grep "for invalid user" | cut -d \: -f 4 | cut -d \  -f 9 | xargs -I addr touch addr;
cat "../$xLOG" | grep -v "for invalid user" | cut -d \: -f 4 | cut -d \  -f 7 | xargs -I addr touch addr;

for xADDR in $(ls -1 * 2>/dev/null); do
  xX=$(grep "$xADDR" "../$xLOG" | wc -l);
  echo "$xX" > "$xADDR";
  chown WWWUSER "$xADDR";
done;

ls -1 * 2>/dev/null | wc -l > "../$xSVC.haxors";
cat "../$xLOG" | wc -l > "../$xSVC.fails";
tRun=$(($(date +%s%N) - tStart));
#echo "$(date -Iseconds)" > "../$xSVC.updated";
echo "$(date)" > "../$xSVC.updated";
echo "$tRun" > "../$xSVC.time";

