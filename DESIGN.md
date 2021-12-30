# SSFW Design

This document outlines the design of **SS:FragWhare**, and goes into detail on some of those descissions.


## Primary Design

Fast, Lightweight (as in Lite), Simple to manage and automate, easily extensible, with output that can be easily analysed and/or incorporated into other solutions.

"Did I mention SSFW has to be Fast _AND_ Lite".


### Initial Concept

The data made available by SSFW was initially meant to be forwarded to, or pulled from, an upstream IP address blocking device, like a gateway DMZ, hub or router, either as a service or as a dedicated piece of hardware, as part of an automated threat response system.

That communication and the way the data was stored, was meant to make it easier to de-escated a treat response automatically. A nice application of this data system would have been a 24 hour automated block facility, with the ability to push or "ask for" longer block periods as needed.

This idea of using an upstream device or service not only helps to protect the greater network, but also would heavily reduce the network traffic within that physical gateway point.

It turns out that an automated treat response system has far more nifarious uses than even you or I could imagine, so yeah, we are not going to code that to be publicly available, and thence abusable by any number of public, private or corporate agencies, thanks very much.

A private handmade system would still be practical, backed by something like **PiHole** or some other _FireWall OS_. However there are other solutions which should also be taken into account on that gateway device, besides the normal DMZ and traffic shaping options, like traffic sculpting, and other protection systems and algorythims.

In the meantime, a "Fast _AND_ Lite" system equivalent to a firewall seemed feasible, and so **SSFW** or **SS:FragWhare**, a "super simple firewall", started life.


### Installation Variables

The `install.sh` script came last, but it will be the first thing you may notice as using a _non-standard_ for of parsing options or presets.

 - Firstly, it is programatically easier to code evvironment variable checks than it is to process command line arguments.
 - Secondly, it is easier to add default manipulations (not used here, they have to be unique anyway).
 - Thridly, command line options could be used to generate random presets.
 - Fourthly, it is easier to lockdown (or detect) optionals or presets that are empty.
 - Fifthly, it means you read at least some of the documentation at installation time, guarenteeing some form of secure installation (or not, because you chose easily detectable presets - you have been warned).
 - Lastly it is easier to programtically run the installer from somewhere else because all options are named and must be present at installation time.

NOTE: this maybe inconvienient on some platforms where `export` is required before environment variables can be used, in which case, make sure you `unset` or otherwise remove them from the environment variable list, they are only used during installation, _NOT_ at runtime.


### File names not File contents

The descission was made early on to be able to use _off-the-shelf_ command line tools to be able to quickly and easily analyse certain aspects of the blocking system, _especially_ if you were on a _single core CPU_ or a _low memory system_.

Because of this, and the fact that the `ls -1` command has automatic ordering and/or sorting of output in a list by default, a `ls -1 | xxx` pipe is faster and has lower overheads than using file contents (or a database) based output system.

Use of the filesystem also eliminates the need to use `sort` and `uniq`, both of which require exponentially more memory as the number of data points goes up, which also makes their use dependant on the amount of ram available to a process, and hence can easily be chrashed when used in a piped command set.

The only exception to this data storage solution (ATM) is the `~block-dir/ipv4/.ranges.ipv4` block list, but that may change in the future. It was just easier to keep a record, and hence the file, in the right place for reference purposes, while excluding it from any file lists, and at the same time, not have to worry about the `/` character which is used when creating the IPv4 CIDR ranges to be blocked.

One drawback of using the filesystem over file contents is that directory listing input to other languages are often _not_ sorted (ie listed in the order they last written to), eg. the PHP views of IPv4 lists use 2 dictionaries, one to order the list, and a second to resort (or "cherry pick") by count. However this is fine, because the _count_ is numerical and actually the contents of a file, so creating the "cherry pick" count list first and then reversing it, is much more efficiant than trying to do a _double ended sort_ on a dictionary list.

A second drawback that others may notice, is that although `ls -1` produces a _human readable list_ , its not 100% numerically ordered in the same way a human would sort the same list. However this is also irrelavent, because its the pattern of the numbers which need to be easily recognised, and are more important than the correctness of the list order.

However one bonus of using the filesystem (even over a database) is that each IPv4 data point can itself contain data, ontop of that already supplied as timestamps. (I may end up adding what service this data point was blocked from, the number of attempts made, and maybe the usernames that were tried, but I dont need that information yet). 

Understanding things like the above points can save you alot of grief from a coding point of view, and a lot of processing power and resources at runtime because of that, while allowing future expansion in various ways.


### Seperator Character

The _hash symbol_ (`#`) was used as the seperator for the SSFW log file contents, because that character is never present in the _browser string_. Its use as a seperator in filenames continued because all other _special characters_ that were not already used by an SH system, also need a preceeding `\` character if typed raw on the command line, while not being needed when quoted.

Its probable this character will be used for the (TODO list) _ranges solution_, but it will also need a seperate folder then, which will make it _less_ convienient to archive, copy or move, but that is a problem for another day.


### Gerka's not Rules

The ascociated installation _baggage_ and its complexity in use, is the main reason for not using `iptables` in the first place, however that IPv4 block list and the ranges block list can still be easily integrated into any firewall software.

The idea behind the _gerka service_ is to create individual _gerka's_ for each service deamon you want to scan log output for. At the moment this is only `sshd`, but another example (that may come into being soon) would be `ftpd`.

It was initially intended to use an `httpd` gerka as well, but after some consideration and initial blocked IPv4 being created, it was found that a _cronjob_ was more cost effective. It still may be feasible yet, as explained next.

The _gerka_ needs to be quick, like really quick, _and_ limit other resource impact at the same time, so they only `tail` the last 10 (or 20 if you like) lines of a log file. Essentially they spend the majority of there life `sleep`ing in the process tree, periodically poping out to "snipe" someone.

"Did I mention SSFW has to be Fast _AND_ Lite".


### Micro Scripts

Part of the philosophy behind POSIX as developed for UNIX, was each command only does one thing, and does it extremely well, because its _not_ doing other things, making it more useful when chained together in piped commands.

The orgins of SSFW come from the _want_ to have a responsive system that could communicate with a gateway firewall, and de-escalate in a similar manor.

Because of these senario's there are individual scripts to manage single tasks, some of which co-opt a lesser script (eg. the `sshd` gerka calls the IPv4 blocker).

Any script that blocks by default, also has an explicit `add` options, as well as a `del` option, which makes there inclusion in other task management quite readable.

One drawback of this is that there are more than a few scripts, and some of which you may never touch again after initial setup (eg the cronjobs).


### SH not BASH

Every system that has the BASH shell, and can run SH (POSIX) shell scripts. Any system that does not have a BASH shell (ie uses ASH or DASH or CSH or KSH), can also run a SH (POSIX) shell script.

Even on Windows machines Cygwin, MinGW and now Windows Subsytem for Linux can all run SH (POSIX) shell scripts.

Even platforms with ancient shell versions, or per file shell commands, can still runs the same SH (POSIX) shell scripts.

As long as the platform or OS has a functioning `ip` command, the SSFW firewall system can be used.

And for those systems that have a seperate firewall box, they most probably will have an `ip` command.

The seperate IPv4 block lists are available for any alternate platforms or OS.

A DMZ firewall that can pre-process any downstream requests, would probably find the URL block list useful as well as the IPv4 block list and ranges, in protecting their internal networks, as well as reducing network traffic.


### Data viewers

The PHP data views are designed to be "nicely" displayed in extrememly old browsers, ones that dont even have CSS + JS. They are simple and quick, avoid programming calculations and data extractions, and are faster because the data they present is piped directly to the web page output. 

However because the data they provide is already present in the filesystem as individual extractions, that data can easily be included in an analysis tool or web fontend, without much trouble.

One data view that is not culmative over a month (presuming the logs are cleaned every month), is the blocked SSH IPv4 addresses. They are solely from the output of the currently available log files.

On a standard Alpine Linux system the system `messages` log only has one rotated version, and is rotated every 200Kb. So if the system is getting hit hard by `sshd` attacks, it will rotate about every 3 hours. ATM there is no reliable way to intercept that rotation in a usable way, that affects the data view as well.

"Did I mention SSFW has to be Fast _AND_ Lite".


## Gerka Origins

The origins of the Gerka's (in my learning) came from their use in the British Army in the Kyber Pass. Although they were initially mostly Scotsman who flashed their kilts at their attackers, the majority of Gerka's today come from those lucky enough to make it through the training school in Napal.

That paragraph is greatly over-simplified, and there is a lot of history to be found elsewhere, should one be so inclined.

On a comparison basis to other intake training, only groups like the SAS, Green Berets, Navy Seals, etc, have it harder, and for those you must already have a certain level service record before you can even try their training, let alone get accepted. If you are in the modern day Gerka units, you have already done that level of training, there is just more of it, and more specialized training, for those units.

Although they do come out of training in platoons of 20-40 people, 2 or 4 Gerkas is all you need to hold a pass, they were (and still are) that terrifyingly effective at their jobs. So why not have a few Gerka's on the firewall.

There is even an old 60's comody call "Up the Kyber Pass".


---

(C) 2021/2022 - Paul Wratt
