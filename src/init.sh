#!/bin/bash

################################
### BEGIN CONFIGURATION AREA ###
################################

# Pathing
	# Server
		bukkitfilename="craftbukkit-1.2.3-R0.1.jar"
		bukkitdir=~/"minecraft/"
		logdir=~/"logs/"
	# Backup
		tempdir=~/"temp/"
		backupdir=~/"minecraft/snapshots/"
		serverbackupdir=~/"backups/server/"
		mysqlbackupdir=~/"backups/mysql/"
	# Path to this script-sets' directory
		scriptdir=~/"scripts/"
	# Full path, including file name, for WG's blacklist.txt
		wgblacklist=${scriptdir}"etc/wgblacklist.txt"
# Twitter (via twidge)
	twitteralerts="true"
	twitteralertsstatus="ALERT: Server process ended improperly, possible crash scenario."

# Other configuration data
	bukkitscreen="bukkit"
	dateformat="$(date '+%Y-%m-%d')"
	timeformat="$(date '+%H-%M-%S')"
	mysqluser=""
	mysqlpass=""

# Custom java binary location. Do not change unless custom installation was done, ex: `/opt/java/bin/java`.
# This assumes java is in the default location: /usr/bin/java.
	javaloc="/usr/lib/jvm/java-6-sun/jre/bin/java"

# Invocation parameters
	bukkitinvocation="$javaloc -server -Xmx1000M -Xincgc -jar $bukkitdir$bukkitfilename nogui"


# Make sure you change this to the name of your world folder!
# Add additional worlds by separating them with a white space. e.g. (world nether pvp chaos blackmesa)
	declare -a worlds=(globalspawn anoreth nether)
	numworlds=${#worlds[@]}

# List the locations of .log files relative to $bukkitdir that you wish to be "rolled over" by the logroll function.
# Do NOT include a file extension or try and use this for non .log files.
	declare -a logroll=(server worldedit)
	numlogroll=${#logroll[@]}

################################
#### END CONFIGURATION AREA ####
################################

forcesavefile=${scriptdir}"etc/forcesave.sh"
twitteralertsfile=${scriptdir}"etc/twitteralerts.sh"
statuslog=${logdir}"status.log"

. $scriptdir"functions/backup.sh"
. $scriptdir"functions/common.sh"
. $scriptdir"functions/control.sh"
. $scriptdir"functions/utilities.sh"
