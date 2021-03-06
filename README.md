* Current script version: 1.1c
* Current config version: 1.1

See *MineControl-latest.sh* for the latest stable script, and *MineControl-latest.conf* for the latest stable configuration.

See *MineControl-dev.sh* and *MineControl-dev.conf* for my development files.

## Features ##

* Easy to configure
* Reliable server control:
 * Runs server in screen session
 * Start server
 * Properly stop server
 * Terminate server process (has built-in safe-guards to prevent accidential use)
 * Can run the server in a loop, meaning that when the process ends it automatically starts again
* World backups (currently supports zip. More compression types to come)
* Forcesave command, Cron ready
* Advanced log functionality
 * Logs all actions by MineControl to file
 * Can 'roll' server.log and worldedit.log into timestamped files on demand or at server shutdown
* Minecraft Overviewer support
 * If the MC server is running, forces a save on it, disables saving, copies specified worlds to temp directory, re-enables saving, then invokes Overviewer
 * Supports Overviewer config paths
 * Built in safe-guards, Cron ready

## Roadmap ##

* 1.1.1
 * Plugin Backups
* 1.1.2
 * Full server backups

## Long-Term ##
 * Fully automated restart with backups
 * Interactive mode
 * Support for various plugins where it may be helpful (i.e. better WorldGuard blacklist editing, copies new blacklist.txt to each worlds directory under WorldGuard/worlds/).

## Requirements ##

You will need to install:

* screen

You should already have:

* bash
* busybox or equivalent for standard Unix commands
* command
* zip

Note that MineControl MUST be run using **bash**, not sh.

## How to Use... ##
### Overviewer ###
Make your overviewer.conf file like you normally would, but specify the world locations as `/home/<linux user>/<temp directory in config>/ovr-<worldname>/` replacing <linux user> with the username of the logged in user, and <worldname> with the name of the world.

## Changelog ##
1.1b 2012/11/08 - 11:21 PM EST

* Fixed the `overviewer start` command ignoring the value of 'overviewer_Enable'
* Improved PID writing for overviewer
* Other small tweaks

1.1a 2012/11/06 - 1:00 PM EST

* Fixed issue with individual world backup
* Other small tweaks

1.1 2012/11/05 - 11:45 PM EST

* Configuration tweaks
 * Moved previously internal variables for the temp and var directories to the conf
 * Moved logs directory into the main MineControl directories block of the conf
 * Added backup directory conf entry
* Added world backups
 * `MineControl.sh backup world`, followed by a world name from the config, or the -all switch.
* Added forcesave command
 * `Minecontrol.sh forcesave`
* Added logging for script actions
 * Log can be found at .minecontrol/minecontrol.log

1.0.9a 2012/10/28 - 8:35 PM EST

* Critical fix in process status checks, because last time it seems to have been a fluke.

1.0.9 2012/10/25 - 03:10 PM EST

* Critical fix in process status checks

1.0.8 2012/10/23 - 08:55 PM EST

* Core - Advanced
 * Added support for taskset (processor affinities)
* Overviewer
 * Changed start command from `overviewer` to `overviewer start`
 * Changed `overviewer start` to abort if overviewer is already running
 * Added isrunning check
 * Added `overviewer status`, `overviewer resume` and `overviewer kill` commands
 * Added configurable announcement to server on completion of render
* Added the ChestShop Bukkit-plugin to log rolling

1.0.7 2012/09/10 - 12:56 PM EST

* Fixed a scripting mistake in the `config bukkit` command
* Updated `log roll` for new `worldedit.log` file location

1.0.6 - 2012/08/25 - 3:25 PM EST

* Fixed critical, gauranteed failure in overviewer functionality

1.0.5 - 2012/08/12 - 10:30 PM EST

* Decreased pause between launching Minecraft/Overviewer and attaching to the screen
* Added arguments for opening server.properties and bukkit.yml for editing

1.0.4 - 2012/08/07 - 06:08 PM EST

* Added option to run server in a loop (automatic restart 10 seconds after it stops with prompt to abort)
* Added Minecraft Overviewer support for easier scheduled rendering

1.0.3 - 2012/04/16 - 10:30 PM EST

* Added server start/stop/kill logging. Can be toggled in the config. *This has since been removed*
* Added 'log rolling.' Currently supports server.log and worldedit.log. Can be toggled in the config

1.0.2 - 2012/03/31 - 10:30 PM EST

* Now stores all MineControl data in ~/.minecontrol/
* Changed to external config file (located in ~/.minecontrol/ by default) so that a users settings can survive an update
* Improved startup checks (downloads latest config if none exists, checks for key directories, server_File, java)
* Added 'editor_Text' to specify the preferred text editor for opening files. Defaults to 'nano'
* Added 'config' parameter to open config in editor of choice.

1.0.1 - 2012/03/22 - 10:00 PM EST

* Improved check for the java binary at the users specified location

1.0 - 2012/03/22 - 8:00 PM EST

* Initial release. Features basic server operation
