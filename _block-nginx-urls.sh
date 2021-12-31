#!/bin/sh
tStart=$(date +%s%N)

### NOTES:
# we process urls into filenames because `ls` will sort them
# and its quicker to produce unique matches (using touch),
# whereas `sort` and `uniq` requires ram to sort them

# where we want to pull the log from
# (to help stop abuse of the script)
D="SSFWROOT/PREFIX_log-dir"

if [ "$1" = "" ]; then
  echo "$0 _log_ (in: $D)"
  exit
fi

if [ ! -e "$D/$1" ]; then
  echo "not found: $D/$1"
  exit
fi

# where are we going to dump the urls as filenames
cd "SSFWROOT/PREFIX_block-dir/urls"

# Nginx: capture and prune both error and access logs
#        remove some legitimate stuff in first grep.
#        eg. '/work/www' is a web path you want pruned
cat "$D/$1" | grep -v "PREFIX\|FILEPRE\|PHP Fatal\|#0 {main}\|Stack trace\|thrown in" | cut -d \" -f 2 | sed 's./work/www..g' | sed 's.GET ..g' | sed 's, HTTP/1.1,,g' | sed 's.Unable to open primary script: ..g' | sed 's. (No such file or directory)..g' | tr '/' ':' | xargs -r -I block_url touch block_url

### Pre-process some urls
# legitimate items we want to ignore
rm -f :var:lib:nginx:* :log:* :stats:* :PREFIX* :FILEPRE*
# items we dont want to block
rm -f : :favicon.ico :index.php :index.html
# items we still want to see captured in block.head
rm -f :robots.txt :ads.txt :.well-known:security.txt :security.txt :sitemap.xml
# items with custom rules in block.head
rm -f *:.env *:print.css *:phpunit*
rm -f *:pma* *:PMA* *:phpmyadmin* *:phpMyAdmin*
# add folder paths without index
ls -1 | grep "index.php$" | sed 's/index.php//g' | xargs -I block_url touch block_url
ls -1 | grep "index.html$" | sed 's/index.html//g' | xargs -I block_url touch block_url

### Create block.conf
# Nginx: include nginx-block.conf;
#      ( ln -s SSFWROOT/b/nginx-block.conf /etc/nginx/nginx-block.conf )
cat ../nginx-block.head  > ../nginx-block.conf
cat ../nginx-block.mime >> ../nginx-block.conf
ls -1 | tr ':' '/'  | sed 's:\(.*\):\*\*location = \1 {|\*\*\*try_files \$uri\*\*/.php-html;|\*\*}:g' | tr '*' '\t' | tr '|' '\n' >> ../nginx-block.conf
cat ../nginx-block.tail >> ../nginx-block.conf

# write some stats
# BusyBox: does _not_ do %N nano-seconds
tRun=$(($(date +%s%N) - tStart));
echo "$(date)" > "$D/../PREFIX_stats-dir/blocks.updated";
echo "$tRun" > "$D/../PREFIX_stats-dir/blocks.time";

