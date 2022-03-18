#!/bin/sh

# NOTE: if the file IS found, it _wont_ appear in 'haxor-access.log',
#       but it _will_ appear in 'nginx-access.log'.

cd "SSFWROOT/PREFIX_tools-dir" ;

# caught "litteral"  ;
grep "x0" "SSFWROOT/PREFIX_log-dir/nginx-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep "passwd" "SSFWROOT/PREFIX_log-dir/nginx-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# "not supported"  ;
#grep '\" 400 \|\" 405 ' "SSFWROOT/PREFIX_log-dir/nginx-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# caught "not supported"  ;
grep '\" 400 \|\" 405 \|\" 200 0 ' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;


### Exploits ###

# Solar Winds
grep "solr" "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# Windows RPC
grep "xlmrpc" "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;


### Hardware Specific ###

# generic direct access
grep "x0" "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep "passwd" "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep "wget" "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep "admin" "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep "setup" "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep "config" "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep "getuser" "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# caught "Netgear" and "Mozi" and "jaws"
# https://blog.lumen.com/new-mozi-malware-family-quietly-amasses-iot-bots/
grep 'setup.cgi?\|shell?' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# BOA webserver exploit on fibre routers
# https://www.theregister.com/2020/04/16/fiber_routers_under_fire/
grep '/boaform/admin/formLogin' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# HNAP, or the Home Network Administration Protocol
# https://routersecurity.org/hnap.php
grep '/HNAP1' /work/www/l/haxors-access.log | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# Dasan GPON home routers
grep '/GponForm/diag_Form' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;


### remark these if not needed (eg #grep ..)

# default "WordPress"
grep '/wp-' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
#grep '/wp-login.php' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
#grep '/wp-content/' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
#grep '/wp-includes/' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# default "phpMyAdmin"
grep 'phpMyAdmin\|MyAdmin\|phpmyadmin\|pma\|PMA' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# Others - might be useful (?)
grep '\.env' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep '/\.aws' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep '/\.DS_Store' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep '/\.ftpconfig' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;


# not sure about this (NOTE: _these_ are common now - 22/03/18) 
# mostly this is one user with '*.linodeusercontent.com' spinups
# using 'python-requests/2.9.1' on unique location Linode servers
# since August 2021 (see: git-config.log.txt)
grep '\.git/config' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep '\.git/HEAD' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep '\.svn' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep '\.hg' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep '\.travis' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep '\.vscode' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;


