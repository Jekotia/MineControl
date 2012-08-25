Current script version: 1.0.6
Current config version: 1.0.5

See *MineControl-latest.sh* for the latest stable release.

Previous releases will be found in *archive/*.

## Features ##

* Easy to configure
* Reliable server control:
 * Runs server in screen session
 * Start server
 * Properly stop server
 * Terminate server process (has built-in safe-guards to prevent accidential use)
* Advanced log functionality
 * Can 'roll' server.log and worldedit.log into timestamped files on demand or at server shutdown.

## Roadmap ##
* 1.1
 * Backups
* Long-Term
 * Force saves with fore-warnings (for use with cron)
 * Nightly restart with log file rotation (for use with cron)
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

## How to Use... ##
### Overviewer ###
Make your overviewer.conf file like you normally would, but specify the world locations as '/home/<linux user>/.minecontrol/temp/ovr-<worldname>' replacing <linux user> with the username of the logged in user, and <worldname> with the name of the world.

## Changelog ##
1.0.6 - 2012/08/25 - 3:25 PM EST

* Fixed critical, gauranteed failure in overviewer functionality.

1.0.5 - 2012/08/12 - 10:30 PM EST

* Decreased pause between launching Minecraft/Overviewer and attaching to the screen.
* Added arguments for opening server.properties and bukkit.yml for editing.

1.0.4 - 2012/08/07 - 06:08 PM EST

* Added option to run server in a loop (automatic restart 10 seconds after it stops with prompt to abort).
* Added Minecraft Overviewer support for easier scheduled rendering.

1.0.3 - 2012/04/16 - 10:30 PM EST

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
