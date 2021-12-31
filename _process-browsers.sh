#!/bin/sh
tStart=$(date +%s%N);
if [ ! -d "../PREFIX_log-dir" ]; then
  echo "not found: ../PREFIX_log-dir";
  exit;
fi;
mkdir -p "../PREFIX_stats-dir/browsers";
rm -f ../PREFIX_stats-dir/browsers/*;

cd "../PREFIX_log-dir";
xLOGS=$(ls -1 *log);
D="../PREFIX_stats-dir/browsers";

recStat()
{
if [ ! "$2" = "0" ]; then
  if [ ! -e "$D/$1" ]; then
    echo "$2" > "$D/$1";
  else
    xZ=$(cat "$D/$1");
    echo "$(expr $xZ + $2)" > "$D/$1";
  fi;
fi;
}

for xLOG in $xLOGS; do
  recStat "architecture-armv5" $(cat $xLOG | grep " armv5" | wc -l);
  recStat "architecture-armv6" $(cat $xLOG | grep " armv6" | wc -l);
  recStat "architecture-armv7" $(cat $xLOG | grep " armv7\|gnueabihf" | wc -l);
  recStat "architecture-aarch64" $(cat $xLOG | grep " aarch64\| armv8" | wc -l);
  recStat "architecture-m68k" $(cat $xLOG | grep -v "m68k-" | grep " 68K\| 68k\|_MC680\|m68k" | wc -l);
  recStat "architecture-ppc" $(cat $xLOG | grep " PPC" | wc -l);
  recStat "architecture-x86" $(cat $xLOG | grep "i386\|i686\| WOW64" | wc -l);
  recStat "architecture-x86_64" $(cat $xLOG | grep " x86_64\| x64\| Intel " | wc -l);
  recStat "operatingsystem-AmigaOS" $(cat $xLOG | grep "AmigaOS" | wc -l);
  recStat "operatingsystem-Android" $(cat $xLOG | grep "Android" | wc -l);
  recStat "operatingsystem-ChromeOS" $(cat $xLOG | grep "CrOS" | wc -l);
  recStat "operatingsystem-Ubuntu" $(cat $xLOG | grep "Ubuntu" | wc -l);
  recStat "operatingsystem-Linux" $(cat $xLOG | grep "Linux\|linux" | grep -v "Android" | wc -l);
  recStat "operatingsystem-MacOS" $(cat $xLOG | grep "Macintosh" | grep -v "Mac OS X" | wc -l);
  recStat "operatingsystem-OSX" $(cat $xLOG | grep "Mac OS X" | grep -v "iPad\|iPhone" | wc -l);
  recStat "operatingsystem-RISCOS" $(cat $xLOG | grep "RISC OS" | wc -l);
  recStat "operatingsystem-Windows_NT" $(cat $xLOG | grep "Windows NT\|WinNT" | wc -l);
  recStat "platform-BSD_Unix" $(cat $xLOG | grep "BSD" | wc -l);
  recStat "platform-iOS" $(cat $xLOG | grep "iPhone\|iPad" | wc -l);
  recStat "platform-Linux" $(cat $xLOG | grep "Linux\|linux" | wc -l);
  recStat "platform-Macintosh" $(cat $xLOG | grep "Macintosh" | wc -l);
  recStat "platform-Windows" $(cat $xLOG | grep "Windows" | wc -l);
  recStat "platform-Dalvik" $(cat $xLOG | grep "Dalvik/" | wc -l);
  recStat "platform-iOS" $(cat $xLOG | grep "iPhone\|iPad" | wc -l);
  recStat "browser-Mobile" $(cat $xLOG | grep " U; \|Mobile\|iPhone\|iPad\|ZTE\|HUAWEI\Huawei\|Nokia" | wc -l);
  recStat "browser-Chinese" $(cat $xLOG | grep "zh-CN;\|UCBrowser\|osee" | wc -l);
  recStat "browser-Chromium" $(cat $xLOG | grep " Chrome/" | wc -l);
  recStat "browser-Edge" $(cat $xLOG | grep " Edg/\| Egde/" | wc -l);
  recStat "browser-Firefox" $(cat $xLOG | grep " Firefox/" | wc -l);
  recStat "browser-Waterfox" $(cat $xLOG | grep " Waterfox/" | wc -l);
  recStat "browser-BonEcho" $(cat $xLOG | grep " BonEcho/" | wc -l);
  recStat "browser-SeaMonkey" $(cat $xLOG | grep " SeaMonkey/" | wc -l);
  recStat "browser-Highwire" $(cat $xLOG | grep "Highwire" | wc -l);
  recStat "browser-Internet_Explorer" $(cat $xLOG | grep " MSIE \|Trident" | wc -l);
  recStat "browser-Internet_Explorer_old" $(cat $xLOG | grep " MSIE " | wc -l);
  recStat "browser-Internet_Explorer_new" $(cat $xLOG | grep "Trident" | wc -l);
  recStat "browser-NetSurf" $(cat $xLOG | grep "NetSurf" | wc -l);
  recStat "browser-UCBrowser" $(cat $xLOG | grep "UCBrowser" | wc -l);
  recStat "browser-OSee" $(cat $xLOG | grep "osee" | wc -l);
  recStat "remote-index" $(cat $xLOG | grep "AhrefsBot\|baidu\|Baiduspider\|BLEXBot\|serpstatbot\|Googlebot\|Favicon\|CCBot" | wc -l);
  recStat "remote-domains" $(cat $xLOG | grep "at.bot\|CentralOps" | wc -l);
  recStat "remote-commercial" $(cat $xLOG | grep "ipip\|webprosbot\|CheckMarkNetwork\|MJ12bot\|gdnplus\|Censys\|NetSystemsResearch\|Expanse\|WordPress\|pdrlabs\|mShots\|185.163.109.66\|192.241.215.92\|shodan.io" | wc -l);
  recStat "remote-probe" $(cat $xLOG | grep "aiohttp\|l9tcpid\|masscan\|Nuclei\|cow\|zgrab\|Java\|Go-http\|python\|Python\|tchelebi\|httpx" | wc -l);
  recStat "remote-cli" $(cat $xLOG | grep "curl\|Wget\|wget" | wc -l);
  recStat "remote-none" $(cat $xLOG | grep "#$" | wc -l);
done;
tRun=$(($(date +%s%N) - tStart));
echo "$(date)" > "../PREFIX_stats-dir/browsers.updated";
echo "$tRun" > "../PREFIX_stats-dir/browsers.time";

