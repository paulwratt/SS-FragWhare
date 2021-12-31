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

# working directory (ie. web server root)
cd "SSFWROOT";

# EG: http://14.17.15.13/unique-svc_php-20210807120051.tar.gz
T=$(date -Iseconds | cut -d \+ -f 1 | tr -d \- | tr -d T | tr -d \:);
N="FILEPRE_php";
A=*.php;
F="$N-$T.tar.$E";
rm -f $N-*.tar.*;
tar -c $C -f "$F" $A;
echo "WWWURLSSFWHEAD/$F";

