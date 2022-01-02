# SS-FragWhare

SSFW is a super simple firewall, based around `ip` command.

Actually its a slightly brutal firewall system (ie FragHaus - "Whare" (farry) is Maori for House). Individual "Gerka" scripts maintain the defence, and can be adjusted from "soft" defence, to "brutal" defence.


## Webserver Configurations

This folder contain pre-configured includes for runtime generation of the specific webserver configuration via the _block urls_ webserver specific scripts.

Anything in the _head_ file needs to be excluded from the data set that creates the location captures, because the settings in _head_ are generic regex, which are overridden by exact location matches (at least in `nginx`).

The _brutality bonus_ for webservers comes from soft-linking the `.env` file in the root of the webserver to a (in my case) 4.5Gb file. All the resulting definitions in the _mime_ include are then soft-linked to that `.env` file, and also recorded in the webserver root.


## Bandwith Usage

Returning a 404 HTTP error can cripple a webserver if the incoming requests are fast enough. This is the reason for the customised _mime_ configuration includes, which also choke the return bandwidth to 1 kilobyte per second. 1K/s is the smallest `nginx` allows, but there is a way to link a file to `/dev/random` to allow a file to have an unlimited length (however ATM I have just forgotten where I saw that example).


---

(C) 2021/2022 - Paul Wratt
