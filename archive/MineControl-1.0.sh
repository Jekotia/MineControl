#!/bin/bash
minecontrol_Version="1.0" # By Jekotia https://github.com/Jekotia/MineControl
################################
### BEGIN CONFIGURATION AREA ###
################################

# Module: Core
	# Essential paths
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

################################
#### END CONFIGURATION AREA ####
################################
if [ ! -d "$server_Dir" ]; then
    echo "Error: The Minecraft server directory specified for server_Dir ($server_Dir) does not exist."
	_error="true"
fi

if [ ! -f "$server_Dir$server_File" ]; then
    echo "Error: The Minecraft server file specified for server_File ($server_File) does not exist."
	_error="true"
fi

if [ ! -f "$java_Loc" ]; then
    echo "Error: The java binary specified for java_Loc ($java_Loc) does not exist."
	_error="true"
fi

if [ "$_error" = "true" ]; then
	exit
fi

java_Invocation="${java_Loc} ${java_Args} -Xmx${java_Mem} -jar ${server_Dir}${server_File} nogui"

startbukkit() {
	if isrunning; then
		echo "Minecraft server is already running."
		exit 0
	else
		echo "Starting Minecraft server..."
		cd $server_Dir
		$java_Invocation
	fi
}

stopbukkit() {
	if isrunning; then
		sendtoscreen "save-all"
		sendtoscreen "stop"
		resumebukkit
		sleep 1
		sendtoscreen "exit"
	else
		echo "Minecraft server is not running."
		exit 0
	fi
}

sendtoscreen() {
	screen -q -S $server_Screen -X stuff "`printf "\r"`"
	screen -q -S $server_Screen -X stuff "$1$(echo -ne '\r')" > /dev/null
}

isrunning() {
	ps ax | grep -v grep | grep -v screen | grep "$server_File" > /dev/null
	return $?
}

resumebukkit() {
	screen -x $server_Screen
}

case $1 in
	status)
		if isrunning; then
			echo "Minecraft server currently ONLINE:"
			# Get the Process ID of running JAR file
			bukkitPID=`ps ax | grep -v grep | grep -v sh | grep -v -i 'screen' | grep "$server_File"`

			# Display process activity information of bukkit (5 character length pID)
			top -n 1 -p ${bukkitPID:0:5} | grep ${bukkitPID:0:5}

			# Display prcoess infomation of bukkit
			echo "$bukkitPID"
		else
			echo "Minecraft server currently OFFLINE"
			exit
		fi
		;;
    start)
        if isrunning; then
            echo "Minecraft server is already running."
            exit 0
        else
            screen -dmS $server_Screen bash $0 start-now
            screen -x $server_Screen
            exit 0
        fi
        ;;
	start-now)
		startbukkit
		;;
	stop)
		stopbukkit
		;;
	resume)
		resumebukkit
		;;
	kill)
		if ! isrunning; then
			echo "No server process detected."
			exit
		fi
		var1="no"
		echo -n "Are you sure you want to do this? [NO/yes] "
		read var1
		if [ "$var1" == "yes" ]; then
			var2="no"
			echo -n "Are you sure you're sure? [NO/yesplz] "
			read var2
			if [ "$var2" == "yesplz" ]; then
				echo "Don't say I didn't warn you..."
				sleep 2

				echo "Attempting to kill rogue $server_File process..."

				# Get the Process ID of running JAR file
				bukkitPID=`ps ax | grep -v grep | grep -v -i tmux | grep -v sh | grep "$server_File"`
				kill -9 ${bukkitPID:0:5}
				sleep 10

				# Check for process status after pkill attempt
				if isrunning; then
					echo "$server_File could not be killed!"
					exit 1
				else
					echo "$server_File process terminated!"
				fi
			fi
		fi
		;;
	version)
		echo "This is version 1.0 of MineControl by Jekotia."
		echo "Source is available at https://github.com/Jekotia/MineControl"
		;;
    help)
        echo "-------------------------------------------------------------------------"
        echo "'$0 status' returns process info from 'ps' and 'top' about the server."
        echo "'$0 start' starts the server in a screen session."
        echo "'$0 stop' sends the stop command to the screen session."
        echo "'$0 resume' attachs your SSH session to the screen session."
        echo "'$0 kill' kills the server process."
		echo "'$0 help' shows this information."
		echo "'$0 version' shows this information."
        echo "-------------------------------------------------------------------------"
        ;;
	*)
		echo "Usage: $0 <status|start|stop|resume|kill|help>"
esac

exit
