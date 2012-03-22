#!/bin/bash
# Lines ending with #/ are marked to be removed from single-file releases as they only pertain to development & testing in a multiple-file environment
################################
### BEGIN CONFIGURATION AREA ###
################################

# Module: Core
		# Essential paths
			# Path to this script-sets' directory #/
				script_Dir=~/"Dropbox/GitHub/MineControl/src/" #/
			# Path to the Minecraft server directory
				server_Dir=~/"Dropbox/GitHub/MineControl/server/"
			# Name of the .jar file to run the server with. This MUST be inside the serverdir as set above.
				server_File="craftbukkit-beta.jar"
			# Name of the screen session to launch the server in
				server_Screen="minecraft"
		# Parameters for starting the Minecraft server
			# Custom java binary location. Do not change unless custom installation was done, ex: `/opt/java/bin/java`.
				java_Loc="java"
			# Max memory for the server to use. This should be a number followed by an 'M' or a 'G', for megabytes or gigabytes
			# e.g. 1000M is the same as 1G.
				java_Mem="1000M"
			# Additional arguments for java.
			# -server is automatically implied on servers, and -Xincgc is recommended for better garbage collection
				java_Args="-server -Xincgc"


		var_Dir=~/"Dropbox/GitHub/MineControl/var/" #/
		forcesave_Enable="false"

# Module: Logs
	# Base logs directory for everything log-related
		log_Dir=~/"Dropbox/GitHub/MineControl/logs/"
	#
		log_status_Enable="false"
	# server.log 'rolling'
		logroll_Enable=false
# Module: Backup
		backup_Enable="false"
	# 
		worldbackupdir=~/"backups/worlds/"
	# 
		serverworldbackupdir=~/"backups/server/"
	# 
		mysqlworldbackupdir=~/"backups/mysql/"


	# Full path, including file name, for WG's blacklist.txt
		wgblacklist=${scriptdir}"etc/wgblacklist.txt"
# Twitter (via twidge)
	twitterAlert_Enable="true"
	twitteralertsstatus="ALERT: Server process ended improperly, possible crash scenario."

# Other configuration data
	dateformat="$(date '+%Y-%m-%d')"
	timeformat="$(date '+%H-%M-%S')"
	mysqluser=""
	mysqlpass=""

# Make sure you change this to the name of your world folder!
# Add additional worlds by separating them with a white space. e.g. (world nether pvp chaos blackmesa)
	declare -a worlds=(globalspawn anoreth nether)
	numworlds=${#worlds[@]}

# List the locations of .log files relative to $serverdir that you wish to be "rolled over" by the logroll function.
# Do NOT include a file extension or try and use this for non .log files.
	declare -a logroll=(server worldedit)
	numlogroll=${#logroll[@]}

################################
#### END CONFIGURATION AREA ####
################################

bukkitinvocation="${java_Loc} ${java_Args} -Xmx${java_Mem} -jar ${server_Dir}${server_File} nogui"

# var_Dir=$script_Dir"var/" # To be uncommented in releases

forcesavefile=${var_Dir}"forcesave.sh"
twitteralertsfile=${var_Dir}"twitteralerts.sh"

logroll_Dir=~/"Dropbox/GitHub/MineControl/logs/server/"
statuslog=${log_Dir}"status.log"

if [ ! -d "$logroll_Dir" ] && [ "$logroll_Enable" = "true" ]; then
    mkdir -p $logroll_Dir
fi

if [ ! -d "$log_Dir" ] && [ "$log_status_Enable" = "true" ]; then
    mkdir -p $log_Dir
fi

if [ ! -d "${var_Dir}" ] && [ "$forcesave_Enable" = "true" ]; then
    mkdir -p ${var_Dir}
fi

. ${script_Dir}"10-control.sh" #/
. ${script_Dir}"15-utilities.sh" #/
. ${script_Dir}"20-backup.sh" #/
. ${script_Dir}"25-common.sh" #/