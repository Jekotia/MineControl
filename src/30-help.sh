#! /bin/bash

case $1 in
    server)
        echo "-------------------------------------------------------------------------"
        echo "'MC status' returns process info from 'ps' and 'top' about the server."
        echo "'MC start' starts the server in a screen session."
        echo "'MC stop' sends the stop command to the screen session."
        echo "'MC resume' attachs your SSH session to the screen session."
        echo "'MC kill' kills the server process."
        echo "-------------------------------------------------------------------------"
        ;;
    util)
        echo "-------------------------------------------------------------------------"
        echo "'MCutil wgb edit' opens the WorldGuard blacklist for editing."
        echo "'MCutil wgb reload' copies the blacklist file into the folders for each"
        echo "world listed in the config, and then sends the 'wg reload' command to the server."
        echo "-------------------------------------------------------------------------"
        echo "'MCutil pex edit' opens the permissions file for editing."
        echo "'MCutil pex reload' Sends the 'pex reload' command to the server."
        echo "-------------------------------------------------------------------------"
        echo "'MCutil ovr update' Updates the Minecraft Overviewer web directory."
        echo "-------------------------------------------------------------------------"
        echo "'MCutil cmd edit' opens CommandHelper's config file for editing."
        echo "'MCutil cmd reload' Sends the 'reloadaliases' command to the server."
        echo "-------------------------------------------------------------------------"
        ;;
    *)
        echo "-------------------------------------------------------------------------"
        echo "'MC' - Type 'MChelp server' for an explanation of the script."
        echo "'MCutil' - Type 'MChelp util' for an explanation of the script."
        echo "'MCcron' - Opens the crontab file in nano. Have the password handy, uses 'sudo'."
        echo "'MCplugins' Changes your active directory to the plugin directory under 'minecraft'."
        echo "'MChelp' - Shows this info."
        echo "-------------------------------------------------------------------------"
esac