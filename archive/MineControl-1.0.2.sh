#!/bin/bash
minecontrol_Version="1.0.2" # By Jekotia https://github.com/Jekotia/MineControl

# WARNING! ONLY CHANGE THE THREE BELOW VARIABLES IF YOU ARE VERY SURE OF WHAT YOU ARE DOING
minecontrol_Dir=~/".minecontrol/"
minecontrol_var_Dir=$minecontrol_Dir"var/"
minecontrol_Conf=$minecontrol_Dir"minecontrol.conf"

# Key checks
if [ ! -d "$minecontrol_Dir" ]; then # Checks if $minecontrol_Dir doesn't exist
	echo "Creating ~/.minecontrol/"
	mkdir $minecontrol_Dir
fi

if [ ! -d "${minecontrol_var_Dir}" ]; then # Checks if $minecontrol_var_Dir doesn't exist
	echo "Creating ~/.minecontrol/var/"
	mkdir -p $minecontrol_var_Dir
fi

if [ ! -f "$minecontrol_Conf" ]; then # Checks if $minecontrol_Conf doesn't exist
	echo "$minecontrol_Conf does not exist. Downloading latest minecontrol.conf..."
	cd $minecontrol_Dir
	wget -v https://raw.github.com/Jekotia/MineControl/master/MineControl-latest.conf && mv MineControl-latest.conf minecontrol.conf && echo "$minecontrol_Conf successfully downloaded. You should edit this file to suit your setup. Use '$0 config' to open the config file for editing at any time." || echo "Failed to download minecontrol.conf!" # Downloads the latest conf file from GitHub
	exit 0
fi

source $minecontrol_Conf # Includes the conf file

if [ ! -d "$server_Dir" ]; then
	echo "Error: The Minecraft server directory specified for server_Dir ($server_Dir) does not exist."
	_error="true"
fi

if [ ! -f "$server_Dir$server_File" ]; then
	echo "Error: The Minecraft server file specified for server_File ($server_File) does not exist."
	_error="true"
fi

command -v $java_Loc >/dev/null || java_err_1="true"

if [ ! -f "$java_Loc" ]; then
	java_err_2="true"
fi

if [ "$java_err_1" = "true" ] && [ "$java_err_2" = "true" ]; then
	echo "Error: The java binary specified for java_Loc ($java_Loc) does not exist."
	_error="true"
fi

# End of tests
if [ "$_error" = "true" ]; then # If any of the tests failed, stop the script.
	exit 0
fi

java_Invocation="${java_Loc} ${java_Args} -Xmx${java_Mem} -jar ${server_Dir}${server_File} nogui" # Fully defined java invocation



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
			exit 0
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
			exit 0
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
					exit 0
				else
					echo "$server_File process terminated!"
				fi
			fi
		fi
		;;
	config)
		$editor_Text $minecontrol_Conf
		;;
	version)
		echo "This is version $minecontrol_Version of MineControl by Jekotia."
		echo "Source is available at https://github.com/Jekotia/MineControl"
		;;
	help)
		echo "-------------------------------------------------------------------------"
		echo "'$0 status' returns process info from 'ps' and 'top' about the server."
		echo "'$0 start' starts the server in a screen session."
		echo "'$0 stop' sends the stop command to the screen session."
		echo "'$0 resume' attachs your SSH session to the screen session."
		echo "'$0 kill' kills the server process."
		echo "'$0 config' opens the config for editing in the text editor specified in editor_Text ($editor_Text)."
		echo "'$0 version' shows the version info."
		echo "'$0 help' shows this information."
		echo "-------------------------------------------------------------------------"
		;;
	*)
		echo "Usage: $0 <status|start|stop|resume|kill|config|version|help>"
esac

exit 0
