#!/bin/sh
tStart=$(date +%s%N);
if [ ! -d "../PREFIX_log-dir" ]; then
  echo "not found: ../PREFIX_log-dir";
  exit;
fi

mkdir -p "../PREFIX_stats-dir/haxors";
chown WWWUSER "../m68k-svr_stats-dir/haxors";
rm -f ../PREFIX_stats-dir/haxors/*;
rm -f ../PREFIX_stats-dir/haxors.unique;
rm -f ../PREFIX_stats-dir/haxors.visits;

cd "../PREFIX_log-dir";
xLOGS="nginx-haxors.log";

for xLOG in $xLOGS; do
  xSVR=$(echo "$xLOG" | cut -d \- -f 1);
  xADRLIST=$(cat "$xLOG" | cut -d \- -f 1 | tr -d \ );
  for xADR in $xADRLIST; do
    if [ ! -x "../PREFIX_stats-dir/$xSVR/$xADR" ]; then
      xX=$(echo "$xADRLIST" | grep "$xADR" | wc -l);
      echo "$xX" > "../PREFIX_stats-dir/$xSVR/$xADR";
      if [ ! -x "../PREFIX_stats-dir/all/$xADR" ]; then
        echo "$xX" > "../PREFIX_stats-dir/all/$xADR";
      else
        xZ=$(cat "../PREFIX_stats-dir/all/$xADR");
        echo "$(expr $xZ + $xX)" > "../PREFIX_stats-dir/all/$xADR";
      fi;
    fi;
  done;
  echo "$(ls -1 ../PREFIX_stats-dir/$xSVR | wc -l)" > "../PREFIX_stats-dir/$xSVR.unique";
  xX=0;
  for F in $(ls -1 ../PREFIX_stats-dir/$xSVR/* 2>/dev/null); do
    xZ=$(cat $F);
    xX=$(expr $xZ + $xX);
  done;
  echo "$xX" > "../PREFIX_stats-dir/$xSVR.visits";
done;
xX=0;
rm -f ../PREFIX_stats-dir/total.unique;
for F in $(ls -1 ../PREFIX_stats-dir/*.unique 2>/dev/null); do
  xZ=$(cat $F);
  xX=$(expr $xZ + $xX);
done;
echo "$xX" > "../PREFIX_stats-dir/total.unique";
xX=0;
rm -f ../PREFIX_stats-dir/total.visits;
for F in $(ls -1 ../PREFIX_stats-dir/*.visits 2>/dev/null); do
  xZ=$(cat $F);
  xX=$(expr $xZ + $xX);
done;
echo "$xX" > "../PREFIX_stats-dir/total.visits";
tRun=$(($(date +%s%N) - tStart));
#echo "$(date -Iseconds)" > "../stats-dir/haxors.updated";
echo "$(date)" > "../PREFIX_stats-dir/haxors.updated";
echo "$tRun" > "../PREFIX_stats-dir/haxors.time";

