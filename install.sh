#!/bin/sh

echo "" ;
echo "SS:FragWhare - super simple firewall - Installation" ;
echo "" ;

if [ "$1" = "--random" ]; then
  if [ "$SSFW_SSFWROOT" = "" ]; then
    SSFW_SSFWROOT="$(uptime | cut -d \  -f 2,4,6 | tr -d \: | tr -d \  | tr -d \,)" ;
#    SSFW_SSFWROOT="$(echo "$SSFW_SSFWROOT" | tr 0123456789 jaibhcgdfe)" ;
  fi ;
  if [ "$SSFW_PREFIX" = "" ]; then
    SSFW_PREFIX="$(date "+%S%H%M")" ;
    SSFW_PREFIX="$(echo "$SSFW_PREFIX" | tr 0123456789 ajbichdgef)" ;
  fi ;
  if [ "$SSFW_FILEPREFIX" = "" ]; then
    SSFW_FILEPREFIX="$(date "+%S%H%M")" ;
    SSFW_FILEPREFIX="$(echo "$SSFW_FILEPREFIX" | tr 0123456789 bacdefghij)" ;
  fi ;
fi ;

if [ "$SSFW_WWWROOT" = "" -o "$SSFW_WWWUSER" = "" -o "$SSFW_WWWURL" = "" -o "$SSFW_PREFIX" = "" ]; then
  echo " usage:" ;
  echo "SSFW_WWWROOT='/web/server/root' SSFW_WWWUSER='www:www' \\" ;
  echo "SSFW_WWWURL='http://some.url/' SSFW_SSFWROOT='a/path/or/not/' \\" ;
  echo "SSFW_PREFIX='unique-svc' SSFW_FILEPREFIX='' install.sh" ;
  echo "" ;
  echo " all these variables _must_ be present in the environment" ;
  echo " - these variable are _only_ used at installation time" ;
  echo "   so make sure they are not permanent afterwards." ;
  echo " - when FILEPREFIX is empty, PREFIX will be used" ;
  echo " - when SSFWROOT is empty or '/', SSFW will be placed" ;
  echo "   relative to the root of the webserver at WWWROOT" ;
  echo " - 'install.sh --random' will set (if not already set)" ;
  echo "   randomized SSFWROOT, PREFIX and FILEPREFIX values" ;
  echo "" ;
  exit ;
fi ;

ERROR=0
ETEXT="" ;

echo "SSFW_WWWROOT: webserver root ($SSFW_WWWROOT)" ;
if [ -d "$SSFW_WWWROOT" ]; then
  echo -n "found: " ;
else
  echo -n "error: does not exist: " ;
  ERROR=1
  ETEXT="$ETEXT SSFW_WWWROOT" ;
fi; 
WWWROOT="$(realpath "$SSFW_WWWROOT")"
echo "$WWWROOT" ;

U="$(echo "$SSFW_WWWUSER" | cut -d \: -f 1 )" ;
G="$(echo "$SSFW_WWWUSER" | cut -d \: -f 2 )" ;
UN="$(id -u $U 2> /dev/null)" ;
GN="$(grep "^$G:" /etc/group | cut -d \: -f 3 )" ;

echo "SSFW_WWWUSER: webserver user ($SSFW_WWWUSER)" ;
if [ ! "$UN" = "" -a ! "$GN" = "" ]; then
  echo -n "found: " ;
else
  echo -n "error: " ;
  ERROR=1
  ETEXT="$ETEXT SSFW_WWWUSER" ;
  if [ "$UN" = "" ]; then
    ETEXT="$ETEXT (user)" ;
  fi ;
  if [ "$GN" = "" ]; then
    ETEXT="$ETEXT (group)" ;
  fi ;
fi ; 
WWWUSER="$UN:$GN" ;
echo "$WWWUSER" ;

D="$(echo "$SSFW_WWWURL" | cut -d \/ -f 3 | cut -d \: -f 1)" ;
P="$(ping -c 1 $D 2>/dev/null | grep "icmp_seq")" ;

echo "SSFW_WWWURL: webserver url ($SSFW_WWWURL)" ;
if [ ! "$P" = "" ]; then
  echo -n "found: " ;
else
  echo -n "error: lookup failed: " ;
  ERROR=1
  ETEXT="$ETEXT SSFW_WWWURL" ;
fi
WWWURL="$SSFW_WWWURL" ;
echo "$D" ;

echo "SSFW_SSFWROOT: firewall root folder ($SSFW_SSFWROOT)" ;
if [ "$SSFW_SSFWROOT" = "/" -o "$SSFW_SSFWROOT" = "" ]; then
  echo -n "$WWWURL = "
else
  echo -n "$WWWURL$SSFW_SSFWROOT/ = "
fi ;
SSFWHEAD="$SSFW_SSFWROOT" ;
SSFWROOT="$(realpath "$WWWROOT/$SSFW_SSFWROOT" 2>/dev/null)"
echo "$WWWROOT/$SSFW_SSFWROOT"

echo "SSFW_PREFIX: firewall folder prefix ($SSFW_PREFIX)" ;
PREFIX="$SSFW_PREFIX" ;
echo "tools-dir: $WWWROOT/$SSFW_SSFWROOT/${PREFIX}_tools-dir" ;
if [ "$SSFW_FILEPREFIX" = "" ]; then
  SSFW_FILEPREFIX="$SSFW_PREFIX" ;
fi ;
echo "SSFW_FILEPREFIX: firewall script prefix ($SSFW_FILEPREFIX)" ;
FILEPRE="$SSFW_FILEPREFIX" ;
echo "script.sh: $WWWROOT/$SSFW_SSFWROOT/${PREFIX}_tools-dir/${FILEPRE}_block-messages-sshd-kex.sh" ;
echo "EXAMPLE URLS: that you could test (if installation completes)" ;
echo "weblog-dir: $WWWURL$SSFW_SSFWROOT/${PREFIX}_log-dir/"
echo "weburl.php: $WWWURL$SSFW_SSFWROOT/${FILEPRE}_stat.php"
echo "" ;

if [ $ERROR -eq 1 -o ! "$ETEXT" = "" ]; then
  echo "errors need fixing for: $ETEXT" ;
  exit ;
fi ;

read -p "Continue with installation? " REPLY ;
if [ ! "$REPLY" = "y" -o ! "$REPLY" = "Y" ]; then
    exit ;
fi ;

mkdir "$SSFWROOT"
mkdir "$SSFWROOT/${PREFIX}_tools-dir"
mkdir "$SSFWROOT/${PREFIX}_log-dir"
mkdir "$SSFWROOT/${PREFIX}_stats-dir"
mkdir "$SSFWROOT/${PREFIX}_block-dir"
mkdir "$SSFWROOT/${PREFIX}_archive-dir"
mkdir "$SSFWROOT/${PREFIX}_cron-dir"
mkdir "$SSFWROOT/${PREFIX}_cron-dir/reboot"
mkdir "$SSFWROOT/${PREFIX}_cron-dir/15min"
mkdir "$SSFWROOT/${PREFIX}_cron-dir/hourly"
mkdir "$SSFWROOT/${PREFIX}_cron-dir/daily"
mkdir "$SSFWROOT/${PREFIX}_cron-dir/weekly"
mkdir "$SSFWROOT/${PREFIX}_cron-dir/monthly"

chown -Rf $WWWUSER "$SSFWROOT"

for F in $(find -name "_*.sh"); do
  $D="$SSFWROOT/${PREFIX}_tools-dir/${FILEPRE}$F" ;
  cp "$F" "$D" ;
  sed -i s,SSFWROOT,${SSFWROOT},g "$D" ;
  sed -i s,SSFWHEAD,${SSFWHEAD},g "$D" ;
  sed -i s,PREFIX,${PREFIX},g "$D" ;
  sed -i s,FILEPRE,${FILEPRE},g "$D" ;
  sed -i s,WWWURL,${WWWURL},g "$D" ;
  sed -i s,WWWUSER,${WWWUSER},g "$D" ;
  chmod -f o+x "$D" ;
  chown -f $WWWUSER "$D" ;
done ;

chown -Rf $WWWUSER "$SSFWROOT"

