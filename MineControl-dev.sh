#!/bin/bash
minecontrol_Version="1.1b" # By Jekotia; https://github.com/Jekotia/MineControl

# WARNING! ONLY CHANGE THE BELOW VARIABLES IF YOU ARE VERY SURE OF WHAT YOU ARE DOING
	minecontrol_Dir=~/".minecontrol/"
	minecontrol_Conf=${minecontrol_Dir}"minecontrol.conf"
	minecontrol_Conf=~/"Dropbox/GitHub/MineControl/MineControl-dev.conf" #/ minecontrol_Conf=${minecontrol_Dir}"minecontrol.conf"
	overviewer_Invocation="$overviewer_Loc --config=$overviewer_config_Loc" # Fully defined overviewer invocation
	java_Invocation="${java_Loc} ${java_Args} -Xmx${java_Mem} -jar ${server_Dir}${server_File} nogui" # Fully defined java invocation
	log_roll_worldedit_Loc="${server_Dir}plugins/WorldEdit/worldedit.log"
	log_roll_chestshop_Loc="${server_Dir}plugins/ChestShop/ChestShop.log"
	server_PID_File="${var_Dir}java.pid"
	overviewer_PID_File="${var_Dir}overviewer.pid"
	forcesave_File="${var_Dir}forcesave.var"
# Kay, stop touching things now. One typo and this script could destroy your server.

_init() {
	# BEGIN Core tests #
	if [ ! -d "${minecontrol_Dir}" ]; then # Checks if ${minecontrol_Dir} doesn't exist
		mkdir ${minecontrol_Dir} && echo "Created ${minecontrol_Dir}" || echo "Failed to create ${minecontrol_Dir} !"
	fi

	if [ ! -d "${var_Dir}" ]; then # Checks if ${var_Dir} doesn't exist
		mkdir -p ${var_Dir} && echo "Created ${var_Dir}" || echo "Failed to create ${var_Dir} !"
	fi

	if [ ! -d "${temp_Dir}" ]; then # Checks if $temp_Dir doesn't exist
		mkdir -p $temp_Dir && echo "Created $temp_Dir" || echo "Failed to create $temp_Dir !"
	fi

	if [ ! -d "${backup_Dir}worlds/" ] && [ "$backup_world_Enable" = "true" ]; then # Checks if ${backup_Dir}worlds/ doesn't exist
		mkdir -p ${backup_Dir}worlds/ && echo "Created ${backup_Dir}worlds/" || echo "Failed to create ${backup_Dir}worlds/ !"
	fi

	if [ ! -d "${log_Dir}" ]; then # Checks if $log_Dir doesn't exist
		mkdir -p $log_Dir && echo "Created $log_Dir" || echo "Failed to create $log_Dir !"
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
	if [ ! -d "${log_Dir}server/" ] && [ "$log_roll_server_Enable" = "true" ]; then # Checks if ${log_Dir}server/ doesn't exist
		mkdir -p ${log_Dir}server/ && echo "Created ${log_Dir}server/" || echo "Failed to create ${log_Dir}server/"
	fi

	if [ ! -d "${log_Dir}worldedit/" ] && [ "$log_roll_worldedit_Enable" = "true" ]; then # Checks if ${log_Dir}worldedit/ doesn't exist
		mkdir -p ${log_Dir}worldedit/ && echo "Created ${log_Dir}worldedit/" || echo "Failed to create ${log_Dir}worldedit/"
	fi

	if [ ! -d "${log_Dir}chestshop/" ] && [ "$log_roll_chestshop_Enable" = "true" ]; then # Checks if ${log_Dir}chestshop/ doesn't exist
		mkdir -p ${log_Dir}chestshop/ && echo "Created ${log_Dir}chestshop/" || echo "Failed to create ${log_Dir}chestshop/"
	fi
	# END Logging tests #

	if [ ! "$1" = "config" ] && [ ! "$1" = "version" ] && [ ! "$1" = "help" ] && [ "$fatal_error" = "true" ]; then
		exit 1
	fi
	if [ ! -f "${log_Dir}minecontrol.log" ]; then
		touch ${minecontrol_Dir}minecontrol.log
	fi
}

_init # Call the _init. TEST ALL THE THINGS!

# BEGIN Common functions #
_common_sendtoscreen() {
		screen -S $server_Screen -p 0 -X stuff "$(printf \\r)" # Submit the current content of the input area in the Minecraft server console to ensure the intended command is sent correctly
		_common_log "Minecraft Server: '$1' sent to server screen."
		screen -S $server_Screen -p 0 -X stuff "$1 $(printf \\r)" # Sends the intended command
}
_common_isrunning() {
	if [ ! -f "$server_PID_File" ]; then
		return 1
	fi

	ps ax | grep -v grep | grep -v screen | grep $(<"$server_PID_File") > /dev/null
	return $?
}
_common_log() {
	if [ "$log_scriptEvents" = "true" ]; then
		if [ "$log_scriptEvents_append" = "true" ]; then
			echo $(date '+%Y-%m-%d')_$(date '+%H-%M-%S')": $1" >> ${minecontrol_Dir}minecontrol.log
		else
			echo $(date '+%Y-%m-%d')_$(date '+%H-%M-%S')": $1" | cat - ${minecontrol_Dir}minecontrol.log > ${temp_Dir}minecontrol.temp && mv ${temp_Dir}minecontrol.temp ${minecontrol_Dir}minecontrol.log
		fi
	fi
}
_common_inArray() { # based on http://stackoverflow.com/q/3685970
	local n=$#
	local value=${!n}
	for ((i=1;i < $#;i++)) {
		if [ "${!i}" == "${value}" ]; then
			return 0
		fi
	}
	echo "n"
	return 1
}
_common_forcesave() {
	if [ "$forcesave_Enable" = "true" ]; then
		if [ $(<"${forcesave_File}") = "enabled" ]; then
			if _common_isrunning; then
				_common_sendtoscreen "save-all"
				_common_log "Forcesave: issued to server screen."
			else
				_common_log "Forcesave: issued with no running server."
			fi
		fi
	fi
}
_common_forcesave_enable() {
	if _common_isrunning && [ "$forcesave_Enable" = "true" ]; then
		echo "enabled" > $forcesave_File
	fi
}
_common_forcesave_disable() {
	if _common_isrunning && [ "$forcesave_Enable" = "true" ]; then
		echo "disabled" > $forcesave_File
	fi
}
# END Common functions #

# BEGIN Core functions #
_core_Status() {
	if _common_isrunning; then
		echo "Running Minecraft server:"

		# Display process activity information of the server (5 character length pID)
		echo -e "\n 'top' process information:"
		top -n 1 -p $(<"$server_PID_File") | grep "PID USER"
		top -n 1 -p $(<"$server_PID_File") | grep $(<"$server_PID_File")

		# Display prcoess infomation of the server
		echo -e "\n 'ps' process information:"
		ps -fp $(<"$server_PID_File")
	else
		echo "There is no Minecraft server currently running."
		exit 0
	fi
}
_core_start_Check() {
	if _common_isrunning; then
		echo "Minecraft server is already running."
	else
		screen -dmS $server_Screen bash $0 start-now # Directs the script to start itself in a screen
		sleep 1
		server_PID=(`ps ax | grep -v grep | grep -v sh | grep -v -i 'screen' | grep "$server_File"`)
		server_PID="${server_PID:0:5}"
		echo "${server_PID}" > $server_PID_File
		if [ "$taskset_Enable" = "true" ]; then
			taskset -pc ${taskset_Processors} ${server_PID}
		fi
		screen -x $server_Screen
	fi
}
_core_Start() {
	if _common_isrunning; then
		echo "Minecraft server is already running."
		exit 1
	else
		echo "Starting Minecraft server..."
		cd $server_Dir

		_common_forcesave_enable

		_common_log "Minecraft Server: started."
		$java_Invocation # Start the server!
		_common_log "Server process: ended. See previous/next entry for cause."

		rm "$server_PID_File"
		if [ "$forcesave_Enable" = "true" ]; then
			rm $forcesave_File
		fi

		if [ "$log_roll_onStop" = "true" ]; then # Roll logs on server stop, if configured to do so.
			_log_roll
		fi
		if [ "$server_loop_Enable" = "true" ]; then
			echo -n "Press Enter to abort the loop. You have 10 seconds before the server restarts: "
			read -t 10 -i "ABORT" -e server_loop_Exit
		else
			server_loop_Exit="ABORT"
		fi
		if [ "$server_loop_Exit" = "ABORT" ]; then
			exit 0
		else
			_common_log "Minecraft Server: starting due to loop configuration."
			screen -dmS $server_Screen bash $0 start-now
		fi
		exit 0
	fi
}
_core_Stop() {
	if _common_isrunning; then
		_common_log "Minecraft Server: 'stop' command issued via MineControl."
		_common_sendtoscreen "save-all"
		_common_sendtoscreen "stop"
		_core_Resume
		exit 0
	else
		echo "Minecraft server is not running."
		exit 1
	fi
}
_core_Resume() {
	screen -x $server_Screen
}
_core_Kill() {
	if ! _common_isrunning; then
		echo "No server process detected."
		exit 1
	else
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
				_common_log "Minecraft Server: process kill attempted."
	
				kill -9 $(<"$server_PID_File")
				sleep 10
	
				# Check for process status after pkill attempt
				if _common_isrunning; then
					echo "$server_File could not be killed!"
					_common_log "Minecraft Server: process kill failed."
					exit 1
				else
					echo "$server_File process terminated!"
					_common_log "Minecraft Server: process kill successful."
					exit 0
				fi
			fi
		fi
	fi
}
# END Core functions #

# BEGIN Backup functions #
_backup_world_compress() {
	cd $temp_Dir
	if [ "$backup_world_Compression" = "zip" ]; then
		mkdir -p ${backup_Dir}worlds/${1}/
		zip -v ${backup_Dir}worlds/${1}/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').zip -r ${1}
		if [ "${?}" -ne "0" ]; then
			_common_log "World Backup, zip: failed to compress ${temp_Dir}${1} to ${backup_Dir}${1}/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').zip"
		else
			_common_log "World Backup, zip: successfully compressed ${temp_Dir}${1} to ${backup_Dir}${1}/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').zip"
		fi
	else
		echo "World Backup: failed. Run with invalid backup_world_Compression value ($backup_world_Compression)."
		_common_log "World Backup: failed. Run with invalid backup_world_Compression value ($backup_world_Compression)."
	fi
}
_backup_world_makeTemp() {
	mkdir -p ${temp_Dir}${1} && echo "Created ${temp_Dir}${1}"
	cp -pR ${server_Dir}${1}/* ${temp_Dir}${1} && echo "Copied ${server_Dir}${1}/* to ${temp_Dir}${1}"
}
_backup_world_cleanup() {
	rm -rf ${temp_Dir}${target_world} && echo "Removed previous ${temp_Dir}${target_world}"
}
_backup_world() {
	bak_numworlds=${#bak_worlds[@]}
	
	if [ "$1" = "-all" ]; then
		if _common_isrunning; then
			_common_sendtoscreen "save-all"
			_common_sendtoscreen "save-off"
		fi

		_common_forcesave_disable

		for ((i=0;i<$bak_numworlds;i++)); do
			_backup_world_makeTemp "${bak_worlds[$i]}"
		done

		_common_forcesave_enable

		if _common_isrunning; then
			_common_sendtoscreen "save-on"
		fi

		for ((i=0;i<$bak_numworlds;i++)); do
			_backup_world_compress "${bak_worlds[$i]}"
		done

		for ((i=0;i<$bak_numworlds;i++)); do
			_backup_world_cleanup "${bak_worlds[$i]}"
		done
	else
		if _common_inArray "${bak_worlds[@]}" $1; then
			if _common_isrunning; then
				_common_sendtoscreen "save-all"
				_common_sendtoscreen "save-off"
			fi

			_common_forcesave_disable
			_backup_world_makeTemp "${1}"
			_common_forcesave_enable

			if _common_isrunning; then
				_common_sendtoscreen "save-on"
			fi

			_backup_world_compress "${1}"
			
			_backup_world_cleanup "${1}"
		else
			echo "'$1' did not match any worlds in the configuration! Backup sequence aborted."
			_common_log "World backup: failed. '$1' did not match any worlds in the configuration."
		fi
	fi
}
# END Backup functions #

# BEGIN Log functions #
_log_Roll() {
	if [ "$log_roll_server_Enable" = "true" ] || [ "$log_roll_worldedit_Enable" = "true" ] || [ "$log_roll_chestshop_Enable" = "true" ]; then
		if _common_isrunning; then
			echo "Stop the Minecraft server before rolling logs!"
			_common_log "Log-roll: failed due to running server."
		else
			if [ "$log_roll_server_Enable" = "true" ]; then
				if [ ! -f "${server_Dir}server.log" ]; then # 
					echo "There is no file to 'roll' at ${server_Dir}server.log"
					_common_log "Log-roll: failed. There is no file to 'roll' at ${server_Dir}server.log"
				else
					mv ${server_Dir}server.log ${log_Dir}server/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').server.log
					if [ "${?}" -ne "0" ]; then
						echo "Failed to move '${server_Dir}server.log' to '${log_Dir}server/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log'"
						_common_log "Log-roll: failed to move '${server_Dir}server.log' to '${log_Dir}server/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log'"
					else
						echo "'${server_Dir}server.log' moved to '${log_Dir}server/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log'"
						_common_log "Log-roll: successfully moved '${server_Dir}server.log' to '${log_Dir}server/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log'"
					fi
				fi
			fi

			if [ "$log_roll_worldedit_Enable" = "true" ]; then
				if [ ! -f "$log_roll_worldedit_Loc" ]; then # 
					echo "There is no file to 'roll' at ${log_roll_worldedit_Loc}"
					_common_log "Log-roll: failed. There is no file to 'roll' at ${log_roll_worldedit_Loc}"
				else
					mv -n ${log_roll_worldedit_Loc} ${log_Dir}worldedit/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').worldedit.log
					if [ "${?}" -ne "0" ]; then
						echo "Log-roll: failed to move '${log_roll_worldedit_Loc}' to '${log_Dir}worldedit/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log'"
						_common_log "Log-roll: failed to move '${log_roll_worldedit_Loc}' to '${log_Dir}worldedit/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log'"
					else
						echo "Log-roll: successfully moved '${log_roll_worldedit_Loc}' to '${log_Dir}worldedit/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log'"
						_common_log "Log-roll: successfully moved '${log_roll_worldedit_Loc}' to '${log_Dir}worldedit/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log'"
					fi
				fi
			fi

			if [ "$log_roll_chestshop_Enable" = "true" ]; then
				if [ ! -f "$log_roll_chestshop_Loc" ]; then # 
					echo "There is no file to 'roll' at ${log_roll_chestshop_Loc}"
					_common_log "Log-roll: failed. There is no file to 'roll' at ${log_roll_chestshop_Loc}"
				else
					mv -n ${log_roll_chestshop_Loc} ${log_Dir}chestshop/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').chestshop.log
					if [ "${?}" -ne "0" ]; then
						echo "Log-roll: failed to move '${log_roll_chestshop_Loc}' to '${log_Dir}chestshop/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log'"
						_common_log "Log-roll: failed to move '${log_roll_chestshop_Loc}' to '${log_Dir}chestshop/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log'"
					else
						echo "Log-roll: successfully moved '${log_roll_chestshop_Loc}' to '${log_Dir}chestshop/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log'"
						_common_log "Log-roll: successfully moved '${log_roll_chestshop_Loc}' to '${log_Dir}chestshop/$(date '+%Y-%m-%d')_$(date '+%H-%M-%S').log'"
					fi
				fi
			fi
		fi
	else
		echo "No logs are currently enabled for rolling."
	fi
}
# END Log functions #

# BEGIN Overviewer functions #
_overviewer_isrunning() {
	if [ ! -f "$overviewer_PID_File" ]; then
		return 1
	fi

	ps ax | grep -v grep | grep -v screen | grep $(<"$overviewer_PID_File") > /dev/null
	return $?
}
_overviewer_Status() {
	if _overviewer_isrunning; then
		echo "Running overviewer instance:"

		# Display process activity information of the server (5 character length pID)
		echo -e "\n 'top' process information:"
		top -n 1 -p $(<"$overviewer_PID_File") | grep "PID USER"
		top -n 1 -p $(<"$overviewer_PID_File") | grep $(<"$overviewer_PID_File")

		# Display prcoess infomation of the server
		echo -e "\n 'ps' process information:"
		ps -fp $(<"$overviewer_PID_File")
	else
		echo "There is overviewer instance currently running."
		exit 0
	fi
}
_overviewer_render_check() {
	if [ "$overviewer_Enable" = "true" ]; then
		echo "Overviewer support is disabled in the MineControl configuration. Aborting."
		exit 0
	fi
	if _overviewer_isrunning; then
		echo "Overviewer is already running!"
		exit 0
	else
		screen -dmS $overviewer_Screen bash $0 overviewer-start # Directs the script to start itself in a screen
		sleep 1
		while [ "$overviewer_PID" = "" ]; do
			overviewer_PID=(`ps ax | grep -v grep | grep -v sh | grep -v -i 'screen' | grep "$overviewer_Loc"`)
			overviewer_PID="${overviewer_PID:0:5}"
			echo "${overviewer_PID}" > $overviewer_PID_File
			sleep 1
		done
		screen -x $overviewer_Screen
	fi
}				
_overviewer_render() {
	if _common_isrunning; then
		_common_sendtoscreen "save-all"
		echo "save-all sent to server"
		_common_sendtoscreen "save-off"
		echo "save-off sent to server"
	fi

	_common_forcesave_disable

	ovr_numworlds=${#ovr_worlds[@]}
	for ((i=0;i<$ovr_numworlds;i++)); do
		mkdir -p ${temp_Dir}ovr-${ovr_worlds[$i]} && echo "Created ${temp_Dir}ovr-${ovr_worlds[$i]}"
		cp -pR ${server_Dir}${ovr_worlds[$i]}/* ${temp_Dir}ovr-${ovr_worlds[$i]} && echo "Copied ${server_Dir}${ovr_worlds[$i]}/* to ${temp_Dir}ovr-${ovr_worlds[$i]}"
	done

	_common_forcesave_enable

	if _common_isrunning; then
		_common_sendtoscreen "save-on"
		echo "save-on sent to server"
	fi

	echo "Starting Overviewer..."
	_common_log "Overviewer: starting render."
	
	$overviewer_Invocation
	if [ "${?}" -ne "0" ]; then
		echo "Overviewer render failed!"
		_common_log "Overviewer: render failed."
	else
		echo "Overviewer render completed successfully!"
		_common_log "Overviewer: render successful."
		if _common_isrunning && [ "$overviewer_announce_Enable" = "true" ]; then
			_common_sendtoscreen "$overviewer_announce_Complete"
		fi
	fi

	rm "$overviewer_PID_File"

	for ((i=0;i<$ovr_numworlds;i++)); do
		rm -rf ${temp_Dir}ovr-${ovr_worlds[$i]} && echo "Removed previous ${temp_Dir}ovr-${ovr_worlds[$i]}"
	done
}
_overviewer_resume() {
	screen -x $overviewer_Screen
}
_overviewer_Kill() {
	if ! _overviewer_isrunning; then
		echo "No overviewer process detected."
		exit 0
	else
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
	
				echo "Attempting to kill rogue $overviewer_Loc process..."
	
				kill -9 $(<"$overviewer_PID_File")
				sleep 10
	
				# Check for process status after pkill attempt
				if _overviewer_isrunning; then
					echo "$overviewer_Loc could not be killed!"
					_common_log "Overviewer: process kill failed."
					exit 1
				else
					echo "$overviewer_Loc process terminated!"
					_common_log "Overviewer: process kill successful."
					exit 0
				fi
			fi
		fi
	fi
}
# END Overviewer functions #

usage() {
	echo ""
	echo "Usage: $0 [command]. Available commands, based on what is enabled in the configuration, are below."
	echo "------ Core ------"
	echo "'$0 status' returns process info from 'ps' and 'top' about the server."
	echo "'$0 start' starts the server in a screen session."
	echo "'$0 stop' sends the stop command to the screen session."
	echo "'$0 resume' attachs your session to the screen session."
	echo "'$0 kill' kills the server process."
	if [ "$forcesave_Enable" = "true" ]; then
		echo "----Forcesave-----"
		echo "'$0 forcesave' forces a world save on the server."		
	fi
	if [ "$backup_world_Enable" = "true" ]; then
		echo "---World Backup---"
		echo "'$0 backup world' followed by either -all for all configured worlds, or a world name."
	fi
	if [ "$log_roll_server_Enable" = "true" ] || [ "$log_roll_worldedit_Enable" = "true" ] || [ "$log_roll_chestshop_Enable" = "true" ]; then
		echo "---- Log Roll ----"
		echo "'$0 log roll' rolls server logs specified in the configuration. Cannot be run when the server is running."
	fi
	echo "---- Utility -----"
	if [ "$overviewer_Enable" = "true" ]; then
		echo "'$0 overviewer status'"
		echo "'$0 overviewer start' disables world saving if the server is running before copying config-specified worlds to a temp location for rendering. Enables world saving after copy operation is complete. Is run in a screen session."
		echo "'$0 overviewer resume' attaches to existing overviewer screen session."
		echo "'$0 overviewer kill' forcibly terminates running overviewer process."
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
		_core_Status
		exit 0
	;;
	start)
		_core_start_Check
		exit 0
	;;
	start-now)
		_core_Start
		exit 0
	;;
	stop)
		_core_Stop
		exit 0
	;;
	resume)
		_core_Resume
		exit 0
	;;
	kill)
		_core_Kill
		exit 0
	;;
# END Core #

	forcesave)
		_common_forcesave
		exit 0
	;;

# BEGIN Backup #
	backup)
		case $2 in
			world)
				if [ "$3" = "" ]; then
					usage
				else
					_backup_world $3
				fi
				exit 0
			;;
			*)
				usage
				exit 0
			;;
		esac
	;;
# END Backup #

# BEGIN Log #
	log)
		case $2 in
			roll)
				_log_Roll
				exit 0
			;;
			*)
				usage
				exit 0
			;;
		esac
	;;
# END Log #

# BEGIN Overviewer #
	overviewer)
		case $2 in
			status)
				_overviewer_status
				exit 0
			;;
			start)
				_overviewer_render_check
				exit 0
			;;
			resume)
				_overviewer_resume
				exit 0
			;;
			kill)
				_overviewer_Kill
				exit 0
			;;
			*)
				usage
				exit 0
			;;
		esac
		usage
		exit 0
	;;
	overviewer-start)
		_overviewer_render
		exit 0
	;;
# END Overviewer #

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
			*)
				if [ "$2" = "" ]; then
					$editor_Text $minecontrol_Conf
				else
					usage
				fi
				exit 0
			;;
		esac
		exit 0
	;;
	version)
		echo "This is version ${minecontrol_Version} of MineControl, by Jekotia."
		echo "You are using version ${minecontrol_conf_Version} of the configuration file."
		echo "Source is available at https://github.com/Jekotia/MineControl"
		exit 0
	;;
# END Util #
	*)
		usage
	;;
esac

exit 0