*src/* contains the source scripts used for development and testing, as it is far easier to work on this suite as multiple files instead of one.
The files in *src/* are not recommended for 'production' server use. Use them at your own risk.

See *MineControl-latest.sh* for the latest stable release.

Previous releases will be found in *archive/*.

----------
## Requirements ##

You will need to install:

* screen

You should already have:

* bash
* busybox (Needed for: echo, grep, kill, ps, sleep, and top. This is responsible for many of the standard *nix commands).
* command

Note that these scripts as a suite MUST be run using **bash**, not sh.

----------
## Changelog ##
1.0.1 - 2012/03/22 - 10:00PM EST

* Improved check for the java binary at the users specified location.

1.0 - 2012/03/22 - 8:00PM EST

* Initial release. Features basic server operation.