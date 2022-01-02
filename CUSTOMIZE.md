# Customising SSFW

Some of the scripts will need to be edited at some point, like the webserver url block data generators, when adding custom _head_ include configuration data, that data then needs to be excluded from the data set when creating the configuration file (at least for `nginx`).


## New Scripts

I would prefer _Gerka's_ too, when supplying service specific additions, but a proto-type based on the original `sshd` gerka will be fine. Like the commit quote I posted in the project README says, the simplicity of SSFW is actually the Gerka's. One script, with instructions in code, one command to run it, logging optional, standalone, nothing else needed.


## Script Engines

All scripts are coded for generic SH Engine processing:

 - Dont post scripts or pull requests for scripts that dont use `#!/bin/sh`. (`#!/bin/env sh` _might_ be ok too).
 - Dont use BASH-isms, no DASH-isms.
 - Dont use Linux (or GNU) specific options, or common use cases, that will then break the script on BSD or other Unix variants.
 - If it doesn't work on your SH engine, find a more generic solution (than what I already have) that does work, and I will accept the patch.


## Archive Scripts

_ALL_ archive scripts have archive format options, but because BusyBox (as used by Alpine Linux) only supports a limited set of the available `tar` archive format options, `--lmza` and `--xz` are remarked out by default. However most non-BusyBox systems _will_ (probably) support them.


## Webserver Specifics

If you are willing to supply the resulting scripts and configuration includes relative to any specific webserver software, I will add them to the project.

The specifics of webservers are the configuration formats, the default of _error log_ and _access log_ as well as default _custom log_ file formats and locations (eg. on `nginx` these are _all_ have different formatting).

Any files that need to be present, but dont pertain to a specific webserver setup, can be left empty, as they are still needed to avoid errors at runtime or installation.


## System Logs

I included code to find `messages.0` (Alpine Linux) or `messages.1` (Debian derivitives like RPiOS) _and_ exclude any `.gz` archived `messages` files, but that might not be enough for your distibution.

The default location of the system messages log is usually `/var/log/messages`, so you will need to edit the `sshd` scripts that access that location, _if_ that location is different.

Also, even if your `sshd` service is _off-the-shelf_ it may still have a different log format from `sshd`, and it will need to be tested. If anyone provides one, I will add that to the project. Just be sure to rename it to something service specific.


---

(C) 2021/2022 - Paul Wratt

