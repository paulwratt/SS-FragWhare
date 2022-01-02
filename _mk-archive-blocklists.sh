#!/bin/sh
if [ "$1" = "-j" -o "$1" = "bz" -o "$1" = "bz2" -o "$1" = "bzip" -o "$1" = "bzip2" ]; then
  C="--bzip2";
  E="bz2";
elif [ "$1" = "-z" -o "$1" = "gz" -o "$1" = "gzip" -o "$1" = "zip" ]; then
  C="--gzip";
  E="gz";
elif [ "$1" = "-Z" -o "$1" = "Z" -o "$1" = "compress" ]; then
  C="--compress";
  E="Z";
#elif [ "$1" = "lzma" ]; then
#  C="--lzma";
#  E="lzma";
#elif [ "$1" = "-J" -o "$1" = "xz" ]; then
#  C="--xz";
#  E="xz";
else
  # default
  C="--gzip";
  E="gz";
fi;

# working directory (ie. block-dir root)
cd "SSFWROOT/PREFIX_block-dir";
# just in case
chown -Rf WWWUSER ./* ;

# EG: http://15.19.19.12/unique-svr_block-dir-20210807120051.tar.gz
T=$(date -Iseconds | cut -d \+ -f 1 | tr -d \- | tr -d T | tr -d \:);
D="ssfw-blocklist-urls";
F="$D-$T.tar.$E";
rm -f $D*;
tar -c $C -f "$F" "urls" ;
echo "WWWURLSSFWHEAD/PREFIX_block-dir/$F";
cd "./urls";
ls -1 | tr ":" "/" > "../$D.txt" ;
chown WWWUSER "../$D.txt";
cd "..";
F="$D.txt-$T.$E";
tar -c $C -f "$F" "$D.txt"
echo "WWWURLSSFWHEAD/PREFIX_block-dir/$F";
D="ssfw-blocklist-ipv4";
F="$D-$T.tar.$E";
rm -f $D*;
cp "./ipv4/.ranges.ipv4" "./ipv4/ssfw.ranges.ipv4.txt";
chown WWWUSER "./ipv4/ssfw.ranges.ipv4.txt";
tar -c $C -f "$F" "ipv4" ;
echo "WWWURLSSFWHEAD/PREFIX_block-dir/$F";
cd "./ipv4";
ls -1 > "../$D.txt" ;
chown WWWUSER "../$D.txt";
cd "..";
F="$D.txt-$T.$E";
tar -c $C -f "$F" "$D.txt"
echo "WWWURLSSFWHEAD/PREFIX_block-dir/$F";
mv "./ipv4/ssfw.ranges.ipv4.txt" "./$D-ranges.txt"
F="$D-ranges.txt-$T.$E"
tar -c $C -f "$F" "$D-ranges.txt"
echo "WWWURLSSFWHEAD/PREFIX_block-dir/$F";
echo " ./FILEPRE_update-lastest-blocklists.sh $T ";

