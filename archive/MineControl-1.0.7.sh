#!/bin/bash
minecontrol_Version="1.0.7" # By Jekotia; https://github.com/Jekotia/MineControl

# BEGIN Volatile user-editable section #
	# WARNING! ONLY CHANGE THE BELOW VARIABLES IF YOU ARE VERY SURE OF WHAT YOU ARE DOING
	minecontrol_Dir=~/".minecontrol/"
	minecontrol_var_Dir=$minecontrol_Dir"var/"
	minecontrol_Conf=$minecontrol_Dir"minecontrol.conf"
	# Kay, stop touching things now.
# END Volatile user-editable section #

source $minecontrol_Conf # Includes the conf file

# BEGIN Core tests #
if [ ! -d "$minecontrol_Dir" ]; then # Checks if $minecontrol_Dir doesn't exist
	mkdir $minecontrol_Dir && echo "Created $minecontrol_Dir" || echo "Failed to create $minecontrol_Dir !"
fi

if [ ! -d "${minecontrol_var_Dir}" ]; then # Checks if $minecontrol_var_Dir doesn't exist
	mkdir -p $minecontrol_var_Dir && echo "Created $minecontrol_var_Dir" || echo "Failed to create $minecontrol_var_Dir !"
fi

if [ ! -f "$minecontrol_Conf" ]; then # Checks if $minecontrol_Conf doesn't exist
	echo "$minecontrol_Conf does not exist. Downloading latest minecontrol.conf..."
	cd $minecontrol_Dir
	wget -v https://raw.github.com/Jekotia/MineControl/master/MineControl-latest.conf && mv MineControl-latest.conf minecontrol.conf && echo "$minecontrol_Conf successfully downloaded. You should edit this file to suit your setup. Use '$0 config' to open the config file for editing at any time." || echo "Failed to download minecontrol.conf!" # Downloads the latest conf file from GitHub
	exit 1
fi

if [ ! -d "$server_Dir" ]; then # Checks if $server_Dir doesn't exist
	echo "Fatal Error: The Minecraft server directory specified for server_Dir ($server_Dir) does not exist."
	fatal_error="true"
fi

if [ ! -f "$server_Dir$server_File" ]; then # Checks if $server_File doesn't exist
	echo "Fatal Error: The Minecraft server file specified for server_File ($server_File) does not exist."
	fatal_error="true"
fi
# END Core tests #

# BEGIN Java tests #
command -v $java_Loc >/dev/null || java_error_1="true" # Checks if $java_Loc doesn't exist as a command

if [ ! -f "$java_Loc" ]; then # Checks if $java_Loc doesn't exist as an absolute path
	java_error_2="true"
fi

if [ "$java_error_1" = "true" ] && [ "$java_error_2" = "true" ]; then # If both tests failed, the specified java binary is not valid
	echo "Fatal Error: The java binary specified for java_Loc ($java_Loc) does not exist."
	fatal_error="true"
fi
# END Java tests #

# BEGIN Logging tests #
if [ ! -d "$log_Dir" ]; then # Checks if $log_Dir doesn't exist
	mkdir -p $log_Dir && echo "Created $log_Dir" || echo "Failed to create $log_Dir"
fi

if [ ! -d "${log_Dir}server/" ] && [ "$log_roll_server_Enable" = "true" ]; then # Checks if ${log_Dir}server/ doesn't exist
	mkdir -p ${log_Dir}server/ && echo "Created ${log_Dir}server/" || echo "Failed to create ${log_Dir}server/"
fi

if [ ! -d "${log_Dir}worldedit/" ] && [ "$log_roll_worldedit_Enable" = "true" ]; then # Checks if ${log_Dir}worldedit/ doesn't exist
	mkdir -p ${log_Dir}worldedit/ && echo "Created ${log_Dir}worldedit/" || echo "Failed to create ${log_Dir}worldedit/"
fi
# END Logging tests #


if [ ! "$1" = "config" ] && [ ! "$1" = "version" ] && [ ! "$1" = "help" ] && [ "$fatal_error" = "true" ]; then
	exit 1
fi

# BEGIN Set internal variables #
	#forcesavefile=${var_Dir}"forcesave.sh"
	overviewer_Invocation="$overviewer_Loc --config=$overviewer_config_Loc" # Fully defined overviewer invocation
	java_Invocation="${java_Loc} ${java_Args} -Xmx${java_Mem} -jar ${server_Dir}${server_File} nogui" # Fully defined java invocation
	temp_Dir=~/".minecontrol/temp/"
# END Set internal variables #

# BEGIN Common functions #
sendtoscreen() {
		screen -S $server_Screen -p 0 -X stuff "$(printf \\r)" # Submit the current content of the input area in the Minecraft server console to ensure the intended command is sent correctly
		screen -S $server_Screen -p 0 -X stuff "$1 $(printf \\r)" # Sends the intended command
}

isrunning() {
	ps ax | grep -v grep | grep -v screen | grep "$server_File" > /dev/null
	return $?
}
# END Common functions #

# BEGIN Core functions #
func_server_Status() {
	if isrunning; then
		echo "Running Minecraft server:"
		# Get the Process ID of running JAR file
		serverPID=`ps ax | grep -v grep | grep -v sh | grep -v -i 'screen' | grep "$server_File"`

		# Display process activity information of the server (5 character length pID)
		top -n 1 -p ${serverPID:0:5} | grep ${serverPID:0:5}

		# Display prcoess infomation of the server
		echo "$serverPID"
	else
		echo "There is no Minecraft server currently running."
		exit 0
	fi
}
func_server_Start() {
	if isrunning; then
		echo "Minecraft server is already running."
		exit 0
	else
		echo "Starting Minecraft server..."
		cd $server_Dir
		#if [ "$forcesave_Enable" = "true" ]; then
		#	echo "forcesave=on" > $forcesavefile
		#fi

		while true
		do
			$java_Invocation # Start the server!
			if [ "$log_roll_onStop" = "true" ]; then # Roll logs on server stop, if configured to do so.
				func_log_roll
			fi
			if [ "$server_loop_Enable" = "true" ]; then
				echo -n "Press Enter to abort the loop. You have 10 seconds before the server restarts: "
				read -t 10 -i "ABORT" -e server_loop_Exit
			else
				server_loop_Exit="ABORT"
			fi
			if [ "$server_loop_Exit" = "ABORT" ]; then
				exit 0
			fi
		done
		#if [ "$forcesave_Enable" = "true" ]; then
		#	echo "forcesave=off" > $forcesavefile
		#fi
		exit 0
	fi
}
func_server_Stop() {
	if isrunning; then
		#if [ "$forcesave_Enable" = "true" ]; then
		#	echo "forcesave=off" > $forcesavefile
		#fi
		sendtoscreen "save-all"
		sendtoscreen "stop"
		func_server_Resume
	else
		echo "Minecraft server is not running."
		exit 0
	fi
}
func_server_Resume() {
	screen -x $server_Screen
}
func_server_Kill() {
	if ! isrunning; then
		echo "No server process detected."
		exit 0
	fi
	are_you_sure="no"
	echo -n "Are you sure you want to do this? [NO/yes] "
	read are_you_sure
	if [ "$are_you_sure" == "yes" ]; then
		are_you_sure="no"
		echo -n "Are you sure you're sure? [NO/yes] "
		read are_you_sure
		if [ "$are_you_sure" == "yes" ]; then
			echo "Don't say I didn't warn you..."
			sleep 1

			echo "Attempting to kill rogue $server_File process..."

			# Get the Process ID of running JAR file
			serverPID=`ps ax | grep -v grep | grep -v -i tmux | grep -v sh | grep "$server_File"`
			kill -9 ${serverPID:0:5}
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
}
# END Core functions #

# BEGIN Log functions #
func_log_roll() {
	if isrunning; then
		echo "Stop the Minecraft server before rolling logs!"
	else
		if [ "$log_roll_server_Enable" = "true" ]; then
			if [ ! -f "${server_Dir}server.log" ]; then # 
				echo "There is no file to 'roll' at ${server_Dir}server.log"
			else
				mv ${server_Dir}server.log ${log_Dir}server/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').server.log && echo "${server_Dir}server.log moved to ${log_Dir}server/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log" || echo "Failed to move ${server_Dir}server.log to ${log_Dir}server/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log"
			fi
		fi

		if [ "$log_roll_worldedit_Enable" = "true" ]; then
			if [ ! -f "${server_Dir}worldedit.log" ]; then # 
				echo "There is no file to 'roll' at ${server_Dir}plugins/WorldEdit/worldedit.log"
			else
				mv -n ${server_Dir}plugins/WorldEdit/worldedit.log ${log_Dir}worldedit/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').worldedit.log && echo "${server_Dir}plugins/WorldEdit/worldedit.log moved to ${log_Dir}worldedit/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log" || echo "Failed to move ${server_Dir}plugins/WorldEdit/worldedit.log to ${log_Dir}worldedit/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log"
			fi
		fi
	fi
}
# END Log functions #

# BEGIN Misc functions #
func_overviewer_render() {
	if isrunning; then
		sendtoscreen "save-all"
		sleep 3
		sendtoscreen "save-off"
	fi

	ovr_numworlds=${#ovr_worlds[@]}

	for ((i=0;i<$ovr_numworlds;i++)); do
		mkdir -p ${temp_Dir}ovr-${ovr_worlds[$i]} && echo "Created ${temp_Dir}ovr-${ovr_worlds[$i]}"
		cp -pR ${server_Dir}${ovr_worlds[$i]}/* ${temp_Dir}/ovr-${ovr_worlds[$i]} && echo "Copied ${server_Dir}${ovr_worlds[$i]}/*	to ${temp_Dir}/ovr-${ovr_worlds[$i]}"
		echo "----------"
	done

	if isrunning; then
		sendtoscreen "save-on"
	fi

	echo "Starting Overviewer..." && $overviewer_Invocation

	for ((i=0;i<$ovr_numworlds;i++)); do
		rm -rf ${temp_Dir}ovr-${ovr_worlds[$i]} && echo "Removed previous ${temp_Dir}ovr-${ovr_worlds[$i]}"
	done

	sleep 120

	exit 0
}
# END Misc functions #

usage() {
	echo ""
	echo "Usage: $0 [command]. Available commands, based on what is enabled in the configuration, are below."
	echo "------ Core ------"
	echo "'$0 status' returns process info from 'ps' and 'top' about the server."
	echo "'$0 start' starts the server in a screen session."
	echo "'$0 stop' sends the stop command to the screen session."
	echo "'$0 resume' attachs your session to the screen session."
	echo "'$0 kill' kills the server process."
	echo "------- Log ------"
	if [ "$log_roll_server_Enable" = "true" ] || [ "$log_roll_worldedit_Enable" = "true" ]; then
		echo "'$0 log roll' rolls server logs specified in the configuration. Cannot be run when the server is running."
	fi
	echo "---- Utility -----"
	if [ "$overviewer_Enable" = "true" ]; then
		echo "'$0 overviewer' disables world saving if the server is running before copying config-specified worlds to a temp location for rendering. Enables world saving after copy operation is complete."
	fi	
	echo "'$0 config' opens the config for editing."
	echo "'$0 config server' opens server.properties for editing."
	echo "'$0 config bukkit' opens bukkit.yml for editing."
	echo "'$0 version' shows the version info."
	echo ""
	exit 0
}

case $1 in
# BEGIN Core #
	status)
		func_server_Status
		exit 0
		;;
	start)
		if isrunning; then
			echo "Minecraft server is already running."
		else
			screen -dmS $server_Screen bash $0 start-now # Directs the script to start itself in a screen
			sleep 1
			screen -x $server_Screen 
		fi
		exit 0
		;;
	start-now)
		func_server_Start
		exit 0
		;;
	stop)
		func_server_Stop
		exit 0
		;;
	resume)
		func_server_Resume
		exit 0
		;;
	kill)
		func_server_Kill
		exit 0
		;;
# END Core #

# BEGIN Log #
	log)
		case $2 in
			roll)
				if [ "$log_roll_worldedit_Enable" = "true" ] || [ "$log_roll_worldedit_Enable" = "true" ]; then
					func_log_roll
					exit 0
				fi
				;;
		esac

		usage
		exit 0
		;;
# END Log #
	overviewer)
		screen -dmS $overviewer_Screen bash $0 overviewer-start # Directs the script to start itself in a screen
		sleep 1
		screen -x $overviewer_Screen
		exit 0
		;;
	overviewer-start)
		func_overviewer_render
		exit 0
		;;
# BEGIN Util #
	config)
		case $2 in
			server)
				if [ -f "${server_Dir}server.properties" ]; then
					$editor_Text ${server_Dir}server.properties
				else
					echo "${server_Dir}server.properties does not exist!"
				fi
				exit 0
				;;
			bukkit)
				if [ -f "${server_Dir}bukkit.yml" ]; then
					$editor_Text ${server_Dir}bukkit.yml
				else
					echo "${server_Dir}bukkit.yml does not exist!"
				fi
				exit 0
				;;
		esac
		$editor_Text $minecontrol_Conf
		exit 0
		;;
	version)
		echo "This is version $minecontrol_Version of MineControl by Jekotia."
		echo "Source is available at https://github.com/Jekotia/MineControl"
		exit 0
		;;
# END Util #
	*)
		usage
esac

exit 0