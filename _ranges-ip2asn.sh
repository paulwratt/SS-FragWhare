#!/bin/sh

if [ "$1" = "" ]; then
  echo "Autonomous System Number from IP address";
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
echo "range: $CIDR";
echo "ASN: AS$ASN";

