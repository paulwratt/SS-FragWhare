# SS-FragWhare

SSFW is a super simple firewall, based around `ip` command.

Actually its a slightly brutal firewall system (ie FragHaus - "Whare" (farry) is Maori for House). Individual "Gerka" scripts maintain the defence, and can be adjusted from "soft" defence, to "brutal" defence.


## Webserver Configurations

This folder contain pre-configured includes for runtime generation of the specific webserver configuration via the _block urls_ webserver specific scripts.

Anything in the _head_ file needs to be excluded from the data set that creates the location captures, because the settings in _head_ are generic regex, which are overridden by exact location matches (at least in `nginx`).


---

(C) 2021/2022 - Paul Wratt
