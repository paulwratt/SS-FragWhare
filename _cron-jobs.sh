#!/bin/sh
cd "SSFWROOT/PREFIX_cron-dir"
if [ "$1" = ""  ]; then
  ls
  exit
fi
CD=$(basename $1);
if [ ! -d "$CD" ]; then
  exit
fi
cd "$CD"
JOBS="$(ls -1)"
for JOB in $JOBS; do
  UG=$(stat -c "%U:%G" "$JOB");
#  U=$(echo "$UG" | cut -d \: -f 1)
#  G=$(echo "$UG" | cut -d \: -f 2)
  if [ "$UG" = "WWWUSER" ]; then
    OK=`./$JOB`
  fi
done
exit
