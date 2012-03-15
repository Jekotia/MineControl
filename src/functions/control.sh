#!/bin/bash

startbukkit() {
	if isrunning; then
		echo "Minecraft server is already running."
		exit 0
	else
		echo "Starting Minecraft server..."
		cd $bukkitdir

		echo "-------------------------- Start Entry --------------------------" >> $statuslog
		echo $dateformat"_"$timeformat "- Server process start logged." >> $statuslog

		if [ "$twitteralerts" == "true" ]; then
			echo "hascrashed=true" > $twitteralertsfile
		fi

		echo "forcesave=on" > $forcesavefile
		$bukkitinvocation

		if [ "$twitteralerts" == "true" ]; then
			. $twitteralertsfile
			if [ "$hascrashed" == "true" ]; then
				twidge update "$twitteralertsstatus"
			fi
		fi
		echo "forcesave=off" > $forcesavefile
		dateformat="$(date '+%Y-%m-%d')"
		timeformat="$(date '+%H-%M-%S')"

		echo $dateformat"_"$timeformat "- Server process end logged." >> $statuslog
		echo "--------------------------- End Entry ---------------------------" >> $statuslog
	fi
}

stopbukkit() {
	if isrunning; then
		# Check for friendlystop trigger; wait if so
		if [ "$1" = "friendly" ]; then
			echo "Sending 5 minute shutown warning"
			sendtoscreen "say Server shutting down for maintenance in 5 minutes."
			sleep 240
			echo "Sending 1 minute shutdown warning"
			sendtoscreen "say Server shutting down for maintenance in 60 seconds."
			sleep 30
			echo "Sending 30 second shutdown warning"
			sendtoscreen "say Server shutting down for maintenance in 30 seconds."
			sleep 20
			echo "Sending 10 second shutdown warning"
			sendtoscreen "say Server shutting down for maintenance in 10 seconds."
			sleep 10
		fi

		echo "hascrashed=false" > $twitteralertsfile
		echo $dateformat"_"$timeformat "- Stop command logged." >> $statuslog
		echo "forcesave=off" > $forcesavefile
		sendtoscreen "save-all"
		sendtoscreen "stop"
		resumebukkit
		# Screen's 'bukkit' window will persist after server stop,
		# this will exit the window. Should not affect tmux as
		# it's window 'bukkit' is already gone.
		sleep 1
		sendtoscreen "exit"
######
#		# Check for process status, waiting 5 seconds for shutdown procedure to finish
#		sleep 60
#		if isrunning; then
#			# Uh-oh!
#			echo "Process failed to stop!"
#
#			# Take more aggresive action against pID
#			echo "Attempting to kill rogue $bukkitfilename process..."
#
#			# Get the Process ID of running JAR file
#			bukkitPID=`ps ax | grep -v grep | grep -v -i tmux | grep -v sh | grep "$bukkitfilename"`
#			kill ${bukkitPID:0:5}
#			sleep 1
#
#			# Check for process status after pkill attempt
#			if isrunning; then
#				echo "$bukkitfilename could not be killed!"
#				exit 1
#			else
#				echo "$bukkitfilename process terminated!"
#			fi
#		else
#			echo "Bukkit server successfully stopped!"
#		fi
######
	else
		echo "Bukkit server is not running."
		exit 0
	fi
}
