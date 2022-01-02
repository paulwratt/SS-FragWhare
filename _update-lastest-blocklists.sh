#!/bin/sh

if [ "$1" = "" ]; then
  echo "run './FILEPRE_mk-archive-blocklists.sh' first";
  exit;
fi;

N="$(echo -n "$1")"
if [ ! $(echo -n "$N" | wc -c) -eq 14 ]; then
  echo "nope: timestamp not correct";
  exit;
fi;

mkdir -p "./ssfw-blocklists/$N" && cd "./ssfw-blocklists/$N"

wget "WWWURLSSFWHEAD/PREFIX_block-dir/ssfw-blocklist-urls-$N.tar.gz"
wget "WWWURLSSFWHEAD/PREFIX_block-dir/ssfw-blocklist-urls.txt-$N.gz"
wget "WWWURLSSFWHEAD/PREFIX_block-dir/ssfw-blocklist-ipv4-$N.tar.gz"
wget "WWWURLSSFWHEAD/PREFIX_block-dir/ssfw-blocklist-ipv4.txt-$N.gz"
wget "WWWURLSSFWHEAD/PREFIX_block-dir/ssfw-blocklist-ipv4-ranges.txt-$N.gz"

cd ..
echo "$N" > latest.txt
cd ..
rm -f ssfw-latest-blocklists.tar.gz
tar -c --gzip -f "ssfw-latest-blocklists.tar.gz" "ssfw-blocklists/$1"

#git add ssfw-blocklists/latest.txt ssfw-blocklists/$N/* ssfw-latest-blocklists.tar.gz
#git commit -m "ssfw-blocklists: updated latest to $N"
#git push

exit 

#example automate

git add ssfs-blocklists/latest/* ssfs-blocklists/20220101041337/* ssfw-latest-blocklists.tar.gz
git commit -m "ssfw-blocklists: updated latest to 20220101041337"
#git push

