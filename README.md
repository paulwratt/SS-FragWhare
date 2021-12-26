# SS-FragWhare

SSFW is a super simple firewall, based around `ip` binary.

Actually its a slightly brutal firewall system (ie FragHaus - "Whare" (farry) is Maori for House). Individual "Gerkas" scripts maintain the defence, and can be adjusted from "soft" defence, to "brutal" defence.

The standalone SS-FragWhare "gerka" script is available on the Level1Techs Forum, along with some studies and analysis on the IP address, ranges, timings, and URL attepmts. The is also a commentary on why it came about, and some associated filesystem driver development discussions.

Super Simple SSHd IP blocking

https://forum.level1techs.com/t/automated-network-threat-response/174480/12

A Simple hits/sec Algorythim

https://forum.level1techs.com/t/automated-network-threat-response/174480/11

Automated Network Threat Response

https://forum.level1techs.com/t/automated-network-threat-response/174480


## What is SSFW

The firewall system is a combination of:

 - web server url "capture" list generator
 - per second log file IPv4 blocker
 - pre-generated block lists

All the shell scripts are written for `#!/bin/sh`, so they should work on any POSIX compliant platform with a shell, including non-Linux systems.


## SSFW Prerequsites

For the PHP viewer scripts any version of PHP will work, as long as it can write its own files and contents. Everything else uses _off-the-shelf_ POSIX commands:

 - `$$` (the currently running script process ID)
 - `ls -1`
 - `grep`
 - `cut`
 - `tail`
 - `sort`
 - `uniq` (only used once with a 10 line tail)
 - `date +s%N%` `date -Iseconds` `date -Ihours`
 - `sed`
 - `find -mtime -1` (`-mtime` works with BusyBox)
 - `mkdir -p`
 - `chmod www:www` (where the script is run as `root`)
 - `crontab` (or any "cronjob" service)
 - `php` (any version with file write access)

NOTE: BusyBox does not support "nanoseconds" output for the `date` command, but it does not "error out" either or otherwise break the scripts. Because BusyBox `find` command has limited time support, we use the `-mtime` option (as opposed to other more appropriate `-?time` options). Also `ls -1` is prefered over `sort` as it requires less memory, and is therefore lighter and faster (due to `ls` having human-readable sorted output by default).


## SSFW Block Lists

The IPv4 and URL block lists are gathered from actual hack attempts. The resulting IPv4 addresses are then assessed (manually) for assignment location and entity, where a blocked range may be generated as a result.

Not all blocked ranges are limited to assigned entity ranges (CIDR), sometimes analysis shows a higher or multiple range exclusion may be more practical.

Web server URL's are mostly due to known exploit paths, known paths on weak hardware or firmware, or common alternate paths to web software. All were collect from actual attempts, of which there are clearly lists available.

Pre-generated block lists are available archived in both text format, and as filesystem entries.


## SSFW Limitations

At the moment only IPv4 addresses are processed and blocked.

Currently only Nginx log files have been tested against, with the target of most common (or any) web servers being added, since the analizers are SH shell scripts.

In actual use, a web server without any content, rotates its log files at a minimum of every three hours (3 hrs), if the server is being hit relatively hard (ie. multiple per second hits from the same or different IPv4 locations).

Currently only the `sshd` log files are analized via service processes ("Gerka" scripts). The success of that script (via its per second setting) is (to a certain degree) dependant on some conditions which are out of any scope of control.

For example, on a 1Gb single core x64 VM running Alpine Linux, a setting of less that 5 seconds can cause the script to miss heavy (per second) `sshd` hits, and maybe caused by underlying system or hardware write caching limitations. IE if they are too fast, the time between actual presence of a log entry will be longer than the attack attepts.

Also over time, one of the checks will incrementally consume more processor CPU % usage (but not memory % usage). Cleaning of the log directory at least every month solves (resets) this problem.

Currently the `sshd` key exchange failure check and resulting IPv4 block is a manual operation. If you attempt to initialize an `ssh kex` and it fails, that IPv4 will be present in the _faulures_ sent to the system logs.

_ANY_ failed `sshd` attempt will also be blocked by the SSH "gerka" service, based on the number of times the that IPv4 is present in the log file, and the setting in the script. A setting of 1 is _brutal_ , and actually means 2 entries. This is fine because `sshd` logs a _disconnect_ for every _failed_ attempt to login.

A certain amount of care needs to be taken, especially on a shared IP address. A custom removal script should be maintained for multiple user SSH access. Linode's default remote SSH access allows standard SSH failures that would normally cause critical access denial to be mitigated, but this is a per hosting service, not gaurenteed to be available.


## Securing SSFW

SSFW uses security by obscurity, which is successful _only_ if unique installation presets are used. The repo software is setup to _not_ function unless installed.

The scripts are designed to be used as the `root` user, and function from within a webserver filesystem tree as the `www` user, while none of those scripts contain any `sudo` commands. The SSH "Gerka" requires running as `root` because they access the system log file which by default, even reading is limited to `root` user.

It may be possible to _adjust_ this in the future, as is done with the default Nginx Access log file (by soft linking it into the web server filesystem tree SSFW log directory).

Only one script (that generates addition 404 urls) works outside of the installed `~tools-dir`, and that is so it can be used to process other non-default location web server error logs. All other scripts must be run from `~tools-dir`, and that path is _NOT_ included in the $PATH environment variable, as both these conditions help with security (you have to know SSFW is present _AND_ ahere it is).

Only actual scripts can be run from the `~cron-dir`, not links to scripts, _AND_ they must be owned by the webserver user, again, to help secure any expoit usage. However the `~cron-dir` is pre-setup with "hourly", "daily", "weekly", and "monthly" sub-folders to make server maintenance easier, and again, only "real" scripts will be executed.

## SSFW Installation

Certain information needs to be known _before_ running the `install.sh` script:

 - webserver root
 - a domain or IP address (used to create URL's)
 - location within webserver root (maps path to URL)
 - SSFW unique folder prefix (folder and script access)
 - SSWF unique script prefix (optionally different)

Example:
``
ssfw-install.sh '/web/server/root' 'http://some.url/' 'a/path/or/not/' 'unique_svr'
``

## SSFW Structure

Before posting the SS:FragWhare system in a GIT repository, I tested it for about 6 months, and the last tweak was made 2 months ago (a fix in the IPv4 regex for `grep`).

``
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

``

The IPv4 recorded in `../b/ipv4` as a filename, where the file contents contains the human readable date when said IPv4 was blocked, which may be different from the `stat` date of the file, due to the fact that the `cron` jobs are for `www` user, but the `ip` command requires root, and we dont use `sudo` (just incase someone hacks your `www` user).

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
