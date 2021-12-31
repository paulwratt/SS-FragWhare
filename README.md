# SS-FragWhare

SSFW is a super simple firewall, based around `ip` command.

Actually its a slightly brutal firewall system (ie FragHaus - "Whare" (farry) is Maori for House). Individual "Gerka" scripts maintain the defence, and can be adjusted from "soft" defence, to "brutal" defence.

The standalone SS-FragWhare "Gerka" script is available on the LevelOneTechs Forum, along with some studies and analysis on the IP addresses, ranges, timings, and URL attempts. There is also a commentary on why and how it came about, as well as some resulting associated filesystem driver development discussions in the later posts of the thread.

**Super Simple SSHd IP blocking**

https://forum.level1techs.com/t/automated-network-threat-response/174480/12

**A Simple hits/sec Algorythim**

https://forum.level1techs.com/t/automated-network-threat-response/174480/11

**Automated Network Threat Response**

https://forum.level1techs.com/t/automated-network-threat-response/174480

**Devember 2021 Project Entry**

https://forum.level1techs.com/t/devember-2021-brutally-simple-firewall/179875


## What is SSFW

The firewall system is a combination of:

 - web server url "capture" list generator
 - per second log file IPv4 blocker
 - pre-generated block list data

SSFW uses shell scripts which are written for `#!/bin/sh` and use the `.sh` extention, so they should work on any POSIX compliant platform with a shell, including non-Linux based systems. You might want to start IPv4 block from a "clean slate" (lots of hosting services are blocked by ranges). You also might want to pre-scan the URL block list for common names and locations _NOT_ to use on your webserver.


## SSFW Prerequisites

For the PHP viewer scripts any version of PHP will work, as long as it can write its own files and contents. Everything else uses _off-the-shelf_ commands:

 - `ip add blackhole` (only accessible as `root`)
 - `$$` (the currently running script process ID)
 - `ls -1` (1 per line, default formatting output used)
 - `echo -n` (used to join the `ip` output to IPv4 logs)
 - `grep` (the heart if the IPv4 gathering and lookup)
 - `cut`  (used extensively, cheap IPv4 formating check)
 - `tail` (10 lines by deafult, but 20 should be fine too)
 - `sort` (used as little as possible)
 - `uniq` (only used once with a 10 line tail)
 - `date +s%N%` `date -Iseconds` `date -Ihours`
 - `sed` (in pipes. only one script uses in-place editing)
 - `find -mtime -1` (`-mtime` works with BusyBox)
 - `mkdir -p` (could be a problem on BSD systems)
 - `chown www:www` (where the script was run as `root`)
 - `chmod a+x` (for the `install.sh` script)
 - `crontab` (or any "cronjob" service)
 - `php` (any version with file write access)


NOTES:

 - BusyBox does not support "nano-seconds" (`%N`) output for the `date +%s%N` command, but it does not "error out" either or otherwise break the scripts (only used to calculate shell script execution times).
 - BusyBox `find` command has limited time support options, so we use the `-mtime` option (as opposed to other more appropriate `-?time` options).
 - Also `ls -1` is prefered over `sort` as it requires less memory, and is therefore lighter and faster (due to `ls` having human-readable ordered output by default).
 - All the shell scripts use the `.sh` extension, and execute via `#!/bin/sh`.


## SSFW Block Lists

The IPv4 and URL block lists are gathered from actual hack attempts. The resulting IPv4 addresses are then assessed (manually) for assignment location and entity, where a blocked range may be generated as a result.

Not all blocked ranges are limited to assigned entity ranges (CIDR), sometimes analysis shows a higher or multiple range exclusion may be more practical.

Web server URL's are mostly due to known exploit paths, known paths on weak hardware or firmware, or common alternate paths to web software. All were collect from actual attempts, of which there are clearly lists available (based on log file analysis).

Pre-generated block lists are available archived in both text format, and as filesystem entries, to make it easier to adapt to any one particular system.

The IPv4 blocking script has a `--load` option that can be used at boot time, to reinstate the block list. The `ip` command does not maintain data across reboots, which is one of the main reasons for other firewall software (like `iptables`).


## SSFW Limitations

At the moment only IPv4 addresses are processed and blocked. It is planned to allow IPv6 blocking, but there is also an inherant problem with this on a per IP address basis, and that is there are exponentially more individual addresses, and so blocking ranges instead is more useful, and frugal with in-kernel memory space (which is how `ip` entries are processed). 

Currently only Nginx log files have been tested against, with the target of most common (or any) web servers being added, since the analysers are SH shell scripts, this task is relatively simple.

In actual use, a web server without any content, rotates its `/var/log/messages` log files at a minimum of every three hours (3 hrs), if the server is being hit relatively hard (ie. multiple per second hits from the same or different IPv4 locations).

Currently only the `sshd` log entries are analysed via _service_ processes ("Gerka" scripts). The success of that script, via its per second setting, is (to a certain degree) dependant on some conditions which are out of any scope of control.

For example, on a 1Gb single core x64 VM running Alpine Linux, after a few thousand blocked IP address have been processed, a setting of less that 5 seconds can cause the script to miss heavy (per second) `sshd` hits, and maybe caused by underlying system or hardware write caching limitations. ie. if they are too fast, the time between actual presence of a log entry will be longer than the attack attempts.

Also over time, one of the checks will incrementally consume more processor CPU % usage (but not memory % usage). Cleaning of the log directory at least every month solves (resets) this problem. A fresh install of SSFW will consume about 0.15% of CPU, while after six months the end of month processing can consume about 10-15% (on a single core VM) on-the-hour via the cronjob processes.

Currently, the `sshd` key exchange (`kex`) failure check and resulting IPv4 block is a manual operation. Realistically this check only needs to be done once per every second log rotation (when there is only one backup log file). If you attempt to initialize your own SSH `kex` and it fails, that IPv4 will be present in the _failures_ sent to the system logs.

_ANY_ failed `sshd` attempt will also be blocked by the SSH "gerka" service, based on the number of times the that IPv4 is present in the log file, and the setting in the script. A setting of 1 is _brutal_ , and actually means 2 entries. This is fine because `sshd` logs a _disconnect_ for every _failed_ attempt to login.

So a certain amount of care needs to be taken, especially on a shared IP address. A custom removal script should be maintained for multiple user SSH access. Linode's control panel remote SSH access (weblish) allows standard SSH failures, that would normally cause critical access denial, to be mitigated. However this is a per hosting service, not gaurenteed to be available, so a regular "check and remove" process or script is more useful to protect against known IP address failures.

The webserver _known urls_ (or _haxor urls_) are generated manually, and by default, in an additive fashion, meaning you can loose your original referenced logs and still maintain an ever growing list. Web based development is not a problem on a server protected with SSFW, as long as you dont generate 404, 405 errors or a 200 reponse with 0 bytes returned (ie. just the header).

At least on Linode, there is no correlation between bandwith usage and `sshd` attempts or webserver returned data, except to say that it can indicate a sustained presence over time. By default it climbs by 8Kbit/s increments. Also note that the "here have this 4.5Gb file for your troubles" _brutality bonus_ served via the webserver _will not be present_ until _after_ the connection is closed. (I believe I have seen one pull of 2.5Gb, which is enough to lock up the probing process).

## Securing SSFW

SSFW uses security by obscurity, which is successful _only_ if unique installation presets are used. The repo software is setup to _not_ function unless installed via the install script, which requires presets to be supplied. These presets affect the web server location, SSFW folder name, _and_ (optionally different) script names.

If you are not an advance *nix user or webserver administrator, then I suggest you look through the _known urls_ block list to see what _NOT_ to use as presets (because they are common targets for probes and resulting _haxor url_ attempts).

The scripts are designed to be used as the `root` user, and function from within a webserver filesystem tree owned by the `www` user (or `www-data` user), however none of those scripts contain any `sudo` commands. The SSH "Gerka" requires running as `root` because they access the system log file which by default, even reading is limited to `root` user.

It may be possible to _adjust_ this in the future, as is done with the default Nginx Access log file (by soft linking it into the web server filesystem tree SSFW log directory, and then setting ownership of that link to the webserver username and group).

Only one script (that generates addition 404 urls for the webserver block list base) works outside of the installed `~tools-dir`, and that is so it can be used to process other non-default location webserver error logs. All other scripts must be run from `~tools-dir`, and that path is _NOT_ included in the $PATH environment variable, as both these conditions help with security (ie. you have to know SSFW is present _AND_ where it is).

Only actual scripts can be run from the `~cron-dir`, not links to scripts, _AND_ they must be owned by the webserver user, again, to help secure any expoit usage. However the `~cron-dir` is pre-setup with "hourly", "daily", "weekly", and "monthly" sub-folders to make server maintenance easier, and again, only "real" scripts will be executed.


## SSFW Installation

Certain information needs to be known _before_ running the `install.sh` script:

 - a functioning webserver root (doesn't have to be Nginx)
 - a user and webserver group (eg. `www:www` or `www-data:www-data`)
 - a working domain or IP address (used to create URL's)
 - location within webserver root (maps path to URL)
 - SSFW unique folder prefix (folder and script access)
 - SSWF unique script prefix (optionally different)

Examples:
```
SSFW_WWWROOT='/web/server/root' SSFW_WWWUSER='www:www' SSFW_WWWURL='http://some.url/' \
SSFW_SSFWROOT='a/path/or/not' SSFW_PREFIX='unique-svc' SSFW_FILEPREFIX='' install.sh
```

```
SSFW_WWWROOT='/web/server/root' SSFW_WWWUSER='www:www' SSFW_WWWURL='http://some.url/' \
SSFW_SSFWROOT='' SSFW_PREFIX='' SSFW_FILEPREFIX='egfw-svc' install.sh --random
```

## SSFW Structure

Before posting the SS:FragWhare firewall system in a GIT repository, I tested it for about 6 months (7 months in 4 days time), and the last tweak was made 2 months ago (a fix in the IPv4 select regex for `grep`, and another different IPv4 lookup regex fix last night).

```
/web/server/root/
  uniq_svr-php_scripts.php
  uniq_svr-tools_dir/
    uniq_svr-sh_scripts.sh
  uniq_svr-cron_dir/
    uniq_svr-cron_scripts.sh
  uniq_svr-stats_dir/
  uniq_svr-log_dir/
    browser-various-log
    nginx-linked-files.log
    gerka-monitor.sshd
    gerka-monitor.sshd.pid
  uniq_svr-block_dir/ipv6/
  uniq_svr-block_dir/ipv4/
    ipv4.address.as.filenames
    192.168.100.200
    .ranges.ipv4
  uniq_svr-block_dir/urls/
    :some:haxor:url:path:
    :some:haxor:url:filename.ext
  uniq_svr-block_dir/
    nginx-block.conf
    nginx-block.head
    nginx-block.mime
    nginx-block.tail
  uniq_svr-archive_dir/2021-07=July_2021/
    uniq_svr-log_dir/*
    uniq_svr-stats_dir/*
    uniq_svr-php_scripts.php.html

chown www:www -r /web/server/root
chmod a+x -r /web/server/root/uniq_svr-tools_dir
chmod a+x -r /web/server/root/uniq_svr-cron_dir
chmod a+x -r /web/server/root/uniq_svr-*.php
```

The IPv4 recorded in `../b/ipv4` is a filename, where the file contents contains the human readable date when said IPv4 was blocked, which may be different from the `stat` date of the file, due to the fact that the `cron` jobs are for `www` user, but the `ip` command requires `root`, and we dont use `sudo` (just incase someone hacks your `www` user). The ranges are recorded in a dot-file (hidden) in `../b/ipv4`.

Webserver readable access is given to the following SSFW folders (via `fancyindex` on Nginx):

 - the SSFW `log` directory
 - the SSFW `stats` directory
 - the SSFW `archive` directory

All other SSFW folders are _not readable_ by the webserver. The following are set to executable:

 - SH scripts in  `~tools_dir/`
 - PHP scripts in `~tools_dir/..`
 - SH scripts in  `~tools_dir/../cron_dir/`


---

(C) 2021/2022 - Paul Wratt
