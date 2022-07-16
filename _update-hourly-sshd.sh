#!/bin/sh

# block directory with IPv4 as filenames  ;
B="../PREFIX_block-dir/ipv4";

# stats directory (as opposed to logs)  ;
S="../PREFIX_stats-dir";

# logs directory  ;
L="../PREFIX_log-dir";

### DONE: FIXME: too open to irregularity (no relavant entries)  ;
# grab everything from last hour  ;
#E=$(date -Ihours --date="@$(($(date +%s) - 3600))" | cut -c -13);
#cat ../PREFIX_log-dir/monitor-ipv4.sshd | grep blackhole | grep $E | wc -l > ../m68k-svr_stats-dir/hourly.sshd;
#chown WWWUSER ../PREFIX_stats-dir/hourly.sshd;
### KEEP: the above is a useful `date` command  ;

# we use `-mmin` and `-mtime` so that it still works with BusyBox  ;
find "$B/" -mmin -60 | wc -l > "$S/hourly.ipv4";
find "$B/" -mtime -1 | wc -l > "$S/daily.ipv4";
ls -1 "$B/" 2>/dev/null | wc -l > "$S/total.ipv4";

# change ownership so web server can use them  ;
# NOTE: if web root is correctly permissioned  ;
#       they will already have that group  ;
chown WWWUSER "$S/hourly.ipv4";
chown WWWUSER "$S/daily.ipv4";
chown WWWUSER "$S/total.ipv4";

# add SSHd updates just because  ;
cat "$L/messages.sshd" | wc -l > "$S/sshd.fails";
ls -1 "$S/sshd/" 2>/dev/null | wc -l > "$S/sshd.haxors";
chown WWWUSER "$S/sshd.fails";
chownWWWUSER "$S/sshd.haxors";

