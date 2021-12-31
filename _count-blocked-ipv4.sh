#!/bin/sh
A=$(ls -1 "SSFWROOT/PREFIX_block-dir/ipv4/" 2>/dev/null | wc -l);
B=$(ip route show | grep blackhole | wc -l);
echo "$B:$A";
