#!/bin/sh

cd "SSFWROOT/PREFIX_tools-dir" ;
# caught "litteral"  ;
grep "x0" "SSFWROOT/PREFIX_log-dir/nginx-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# "not supported"  ;
#grep '\" 400 \|\" 405 ' "SSFWROOT/PREFIX_log-dir/nginx-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# caught "not supported"  ;
grep '\" 400 \|\" 405 \|\" 200 0 ' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# caught "Netgear" and "Mozi"  ;
# https://blog.lumen.com/new-mozi-malware-family-quietly-amasses-iot-bots/
grep 'setup.cgi?\|/shell?' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# BOA webserver exploit on fibre routers
# https://www.theregister.com/2020/04/16/fiber_routers_under_fire/
grep '/boaform/admin/formLogin' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# HNAP, or the Home Network Administration Protocol
# https://routersecurity.org/hnap.php
grep '/HNAP1' /work/www/l/haxors-access.log | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# Dasan GPON home routers
grep '/GponForm/diag_Form' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;


### remark these if needed (eg #grep ..)

# default "WordPress"
grep '/wp-login.php' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;
grep '/wp-content/' /work/www/l/haxors-access.log | cut -d \  -f 1 | xargs -n 1 -I {} ./m68k-svr_block-ipv4-addr.sh {} false;

# default "phpMyAdmin"
grep '/phpMyAdmin\|/phpmyadmin' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;

# might be useful (?)
grep '/.env' "SSFWROOT/PREFIX_log-dir/haxors-access.log" | cut -d \  -f 1 | xargs -n 1 -I {} ./PREFIX_block-ipv4-addr.sh {} false;


