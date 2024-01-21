#!/bin/sh

if [ "$1" = "" ]; then
  echo "List IPv4 ranges assigned to ASN for IP address";
  echo "usage: $(basename $0) 192.168.1.12";
  exit;
fi;

IP="$(echo "$1" | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")";

# make sure IPv4 is at least valid
C=$(echo "$IP" | wc -c);
D=$(echo "$IP" | cut -d \. -f 4);
if [ $C -lt 7 -o -z "$D" ]; then
  echo "error: not IPv4: $IP";
  exit;
fi;

A="$(curl -s https://freeapi.dnslytics.net/v1/ip2asn/$IP)";

# check if the results are an announced IP address
# and therefore has an ASN
if [ "$(echo "$A" | grep true)" = "" ]; then
  echo "announced: false";
  exit;
fi;

CIDR="$(echo "$A" | cut -d \" -f 10)";
ASN="$(echo "$A" | cut -d \" -f 13 | grep -E -o "[0-9]{3,6}")";

#curl -s "https://www.dan.me.uk/bgplookup?asn=$ASN" | grep '^<tr><td' | grep -v : | cut -d \  -f 4 ;
curl -s "https://www.dan.me.uk/bgplookup?asn=$ASN" | grep -v '<' |grep ".*/" | cut -c -18 | tr -d \  ;

