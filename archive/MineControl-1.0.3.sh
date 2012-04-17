#!/bin/bash
minecontrol_Version="1.0.3" # By Jekotia https://github.com/Jekotia/MineControl

# BEGIN Volatile user-editable section #
	# WARNING! ONLY CHANGE THE THREE BELOW VARIABLES IF YOU ARE VERY SURE OF WHAT YOU ARE DOING
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
		exit 0
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
	if [ ! -d "$log_Dir" ] && [ "$log_status_Enable" = "true" ]; then # Checks if $log_Dir doesn't exist
		mkdir -p $log_Dir && echo "Created $log_Dir" || echo "Failed to create $log_Dir"
	fi

	if [ ! -d "${log_Dir}server/" ] && [ "$log_roll_server_Enable" = "true" ]; then # Checks if ${log_Dir}server/ doesn't exist
		mkdir -p ${log_Dir}server/ && echo "Created ${log_Dir}server/" || echo "Failed to create ${log_Dir}server/"
	fi

	if [ ! -d "${log_Dir}worldedit/" ] && [ "$log_roll_worldedit_Enable" = "true" ]; then # Checks if ${log_Dir}worldedit/ doesn't exist
		mkdir -p ${log_Dir}worldedit/ && echo "Created ${log_Dir}worldedit/" || echo "Failed to create ${log_Dir}worldedit/"
	fi
# END Logging tests #

if [ "$fatal_error" = "true" ]; then # If any key tests failed, stop the script.
	exit 0
fi

# BEGIN Set internal variables #
	var_Dir=$script_Dir"var/"
	log_status_File=${log_Dir}"status.log"
# END Set internal variables #

java_Invocation="${java_Loc} ${java_Args} -Xmx${java_Mem} -jar ${server_Dir}${server_File} nogui" # Fully defined java invocation

# BEGIN Common functions #
	sendtoscreen() {
		screen -q -S $server_Screen -X stuff "`printf "\r"`" # Submit the current content of the input area in the Minecraft server console to ensure the intended command is sent correctly
		screen -q -S $server_Screen -X stuff "$1$(echo -ne '\r')" > /dev/null # Sends the intended command
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

			if [ "$log_status_Enable" = "true" ]; then
				echo "-------------------------- Start Entry --------------------------" >> $log_status_File
				echo $(date '+%Y-%m-%d')"_"$(date '+%H-%M-%S') "- Server process start logged." >> $log_status_File
			fi

			$java_Invocation # Start the server!

			if [ "$log_status_Enable" = "true" ]; then
				echo $(date '+%Y-%m-%d')"_"$(date '+%H-%M-%S') "- Server process end logged." >> $log_status_File
				echo "--------------------------- End Entry ---------------------------" >> $log_status_File
			fi
		fi
	}
	func_server_Stop() {
		if isrunning; then
			if [ "$log_status_Enable" = "true" ]; then
				echo $(date '+%Y-%m-%d')"_"$(date '+%H-%M-%S') "- Stop command logged." >> $log_status_File
			fi

			sendtoscreen "save-all"
			sendtoscreen "stop"
			func_server_Resume
			sleep 2
			sendtoscreen "exit"
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

		if [ "$log_status_Enable" = "true" ]; then
			echo $(date '+%Y-%m-%d')"_"$(date '+%H-%M-%S') "- Kill command logged." >> $log_status_File
		fi

		are_you_sure="no"
		echo -n "Are you sure you want to do this? [NO/yes] "
		read are_you_sure
		if [ "$are_you_sure" == "yes" ]; then
			are_you_sure="no"
			echo -n "Are you sure you're sure? [NO/yesplz] "
			read are_you_sure
			if [ "$are_you_sure" == "yesplz" ]; then
				echo "Don't say I didn't warn you..."
				sleep 2

				echo "Attempting to kill rogue $server_File process..."

				# Get the Process ID of running JAR file
				serverPID=`ps ax | grep -v grep | grep -v -i tmux | grep -v sh | grep "$server_File"`
				kill -9 ${serverPID:0:5}
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
					mv ${server_Dir}server.log ${log_Dir}server/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log && echo "${server_Dir}server.log moved to ${log_Dir}server/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log" || echo "Failed to move ${server_Dir}server.log to ${log_Dir}server/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log"
				fi
			fi

			if [ "$log_roll_worldedit_Enable" = "true" ]; then
				if [ ! -f "${server_Dir}worldedit.log" ]; then # 
					echo "There is no file to 'roll' at ${server_Dir}worldedit.log"
				else
					mv -n ${server_Dir}worldedit.log ${log_Dir}worldedit/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log && echo "${server_Dir}worldedit.log moved to ${log_Dir}worldedit/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log" || echo "Failed to move ${server_Dir}worldedit.log to ${log_Dir}worldedit/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log"
				fi
			fi
		fi
	}
# END Log functions #

usage() {
	echo "Usage: $0 [command]. Available commands, based on what is enabled in the configuration, are below."
	echo "Core: <status|start|stop|resume|kill>"
	if [ "$log_roll_server_Enable" = "true" ] || [ "$log_roll_worldedit_Enable" = "true" ]; then
		echo "Log: log <roll>"
	fi
	echo "Util: <config|version|help>"
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
			sleep 3
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

# BEGIN Util #
	config)
		$editor_Text $minecontrol_Conf
		exit 0
		;;
	version)
		echo "This is version $minecontrol_Version of MineControl by Jekotia."
		echo "Source is available at https://github.com/Jekotia/MineControl"
		exit 0
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
		exit 0
		;;
# END Util #

	*)
		usage
esac

exit 0