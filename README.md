*src/* contains the source scripts used for development and testing, as it is far easier to work on this suite as multiple files instead of one.
The files in *src/* are not recommended for 'production' server use. Use them at your own risk.

See *MineControl-latest.sh* for the latest stable release.

Previous releases will be found in *archive/*.

## Features ##

* Easy to configure
* Reliable server control:
 * Runs server in screen session
 * Start server
 * Properly stop server
 * Terminate server process (has built-in safe-guards to prevent accidential use)

## Planned Features ##

* Backups
* Force saves with fore-warnings (for use with cron)
* Nightly restart with log file rotation (for use with cron)
* Minecraft Overviewer support for easier scheduled rendering
* Option to run server in a loop (automatic restart in the event of a crash)
* Interactive mode
* Support for various plugins where it may be helpful (i.e. better WorldGuard blacklist editing, copies new blacklist.txt to each worlds directory under WorldGuard/worlds/).

## Requirements ##

You will need to install:

* screen

You should already have:

* bash
* busybox (Needed for: echo, grep, kill, ps, sleep, and top. This is responsible for many of the standard *nix commands. If you don't already have this, something is horribly wrong).
* command

Note that MineControl MUST be run using **bash**, not sh.

## Changelog ##
1.0.3 - 2012/04/XX - XX:XX PM EST

* Added server start/stop/kill logging. Can be toggled in the config.
* Added 'log rolling.' Currently supports server.log and worldedit.log. Can be toggled in the config.
* Refactored much of the project.

1.0.2 - 2012/03/31 - 10:30 PM EST

* Now stores all MineControl data in ~/.minecontrol/.
* Changed to external config file (located in ~/.minecontrol/ by default) so that a users settings can survive an update.
* Improved startup checks (downloads latest config if none exists, checks for key directories, server_File, java).
* Added 'editor_Text' to specify the preferred text editor for opening files. Defaults to 'nano'.
* Added 'config' parameter to open config in editor of choice.

1.0.1 - 2012/03/22 - 10:00 PM EST

* Improved check for the java binary at the users specified location.

1.0 - 2012/03/22 - 8:00 PM EST

* Initial release. Features basic server operation.
