#!/bin/sh
tStart=$(date +%s%N);
if [ ! -d "../PREFIX_log-dir" ]; then
  echo "not found: ../PREFIX_log-dir";
  exit;
fi

mkdir -p "../PREFIX_stats-dir/all";
chown WWWUSER "../PREFIX_stats-dir/all";
rm -f ../PREFIX_stats-dir/all/*;
rm -f ../PREFIX_stats-dir/total.unique
rm -f ../PREFIX_stats-dir/total.visits

cd "../PREFIX_log-dir";
xLOGS=$(ls -1 browser-*);
#xURLS=$(echo "$xLOGS" | cut -d \- -f 2);
for xLOG in $xLOGS; do
  xSVR=$(echo "$xLOG" | cut -d \- -f 2);
  if [ "$xSVR" = "" ]; then
    xSVR="noaddr";
  fi;
  mkdir -p "../PREFIX_stats-dir/$xSVR";
  chown WWWUSER "../PREFIX_stats-dir/$SVR";
  rm -f ../PREFIX_stats-dir/$xSVR/*;
  xADRLIST=$(cat "$xLOG" | cut -d \# -f 2);
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
for F in $(ls -1 ../PREFIX_stats-dir/*.unique 2>/dev/null); do
  xZ=$(cat $F);
  xX=$(expr $xZ + $xX);
done;
echo "$xX" > "../PREFIX_stats-dir/total.unique";
xX=0;
for F in $(ls -1 ../PREFIX_stats-dir/*.visits 2>/dev/null); do
  xZ=$(cat $F);
  xX=$(expr $xZ + $xX);
done;
echo "$xX" > "../PREFIX_stats-dir/total.visits";
tRun=$(($(date +%s%N) - tStart));
#echo "$(date -Iseconds)" > "../stats-dir/last.updated";
echo "$(date)" > "../PREFIX_stats-dir/last.updated";
echo "$tRun" > "../PREFIX_stats-dir/run.time";

