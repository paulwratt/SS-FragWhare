# D="$(date "+%Y-%m=%B_%Y")";
#cd ../a/2021-09=September_2021
if [ "$(realpath "$(pwd)" | grep "archive-dir" | grep "=")" = "" ]; then
  echo "error: run this script from inside an archive folder" ;
  echo " cd ../PREFIX_archive-dir/2021-09=September_2021" ;
  exit ;
fi ;

# get "logs" and "stats" (used in web output)
cp -r ../../PREFIX_log-dir ./
cp -r ../../PREFIX_stats-dir ./
# make shortcuts
ln -s PREFIX_log-dir l
ln -s PREFIX_stats-dir s

# replace softlinks with real files
rm ./l/nginx-*.log
cp /var/log/www/nginx-*.log ./l/

# download all web pages, archive as static html
wget "WWWURLSSFWHEAD/FILEPRE_stats.php"
wget "WWWURLSSFWHEAD/FILEPRE_blocks.php"
wget "WWWURLSSFWHEAD/FILEPRE_browsers.php"
wget "WWWURLSSFWHEAD/FILEPRE_haxors.php"
wget "WWWURLSSFWHEAD/FILEPRE_sshd.php"
wget "WWWURLSSFWHEAD/FILEPRE_log-list.php"

#-- does not work with BusyBox (parameters) --
#-- wget --recursive --no-parent --no-clobber --no-directories --adjust-extension "WWWURLSSFWHEAD/FILEPRE_log-list.php?"
#--

wget "WWWURLSSFWHEAD/FILEPRE_log-list.php?"
wget "WWWURLSSFWHEAD/FILEPRE_log-list.php?log="
### change and enable the next 2 lines as needed, they are
### the urls assigned to your IPv4 address by your hosting
### service
#wget "WWWURLSSFWHEAD/FILEPRE_log-list.php?log=li2255-88.members.linode.com"
#wget "WWWURLSSFWHEAD/FILEPRE_log-list.php?log=li2255-88.members.linode.com:80"

#-- does not work with BusyBox (wget or xargs?)
#-- ls -1 ./l/*-log | cut -d \- -f 2 | grep -v li2255 | xargs -n 1 -I {} wget "WWWURLSSFWHEAD/FILEPRE_log-list.php?log={}"
#--

# grab individual browser log entries  ;
for L in $(ls -1 ./l/*-log | cut -d \- -f 2 | grep -v li2255); do wget "WWWURLSSFWHEAD/FILEPRE_log-list.php?log=$L"; done;
# rename all downloaded .php, add .html  ;
ls -1 *.php* | xargs -n 1 -I {} mv {} ./{}.html;

# change default ownership
cd ../ ;
chown -Rf WWWUSER *

cd "../PREFIX_log-dir" ;
# remove old logs  ;
rm -f ./browser-*-log;
# "zero" specific logs (ie. dont delete = you have been warned)  ;
echo -n "" > ./haxors-access.log;
echo -n "" > ./nginx-access.log;
echo -n "" > ./nginx-errors.log; 
echo -n "" > ./messages.sshd;
echo -n "" > ./monitor-ipv4.sshd;

cd "../PREFIX_stats-dir" ;
# "zero" stats counters  ;
rm ./sshd/*
echo "0" > ./sshd.haxors;
echo "0" > ./sshd.fails;
for F in $(ls -1 *.unique); do echo "0" > "./$F"; done;
for F in $(ls -1 *.visits); do echo "0" > "./$F"; done;
for F in $(ls -1 *.time); do echo "-1" > "./$F"; done;
for F in $(ls -1 *.updated); do echo "$(date)" > "./$F"; done;

# update specific files for web stuff
cd "../PREFIX_tools-dir" ;
./FILEPRE_update-hourly-sshd.sh
