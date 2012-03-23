#!/bin/bash
. ${HOME}/Dropbox/GitHub/MineControl/src/05-init.sh

help(){
# echo "Usage: $0 [status|start|stop|restart|friendlystop|resume]"
	echo "Usage: MC <status|start|stop|resume|kill>"
}

case $1 in
	status)
		if isrunning; then
			echo "Minecraft server currently ONLINE:"
			# Get the Process ID of running JAR file
			serverPID=`ps ax | grep -v grep | grep -v sh | grep -v -i 'screen' | grep "$server_File"`

			# Display process activity information of java (5 character length pID)
			top -n 1 -p ${serverPID:0:5} | grep ${serverPID:0:5}

			# Display process infomation of java
			echo "$serverPID"
		else
			echo "Minecraft server currently OFFLINE"
			exit
		fi
		;;
	start)
		server_Start
		;;
	stop)
		server_Stop
		;;
	restart)
		#server_Stop
		#sleep 5
		#server_Start
		echo "Needs testing still. Sorry!"
		;;
	friendlystop)
		#stop friendly
		echo "Needs testing still. Sorry!"
		;;
	resume)
		server_Resume
		;;
	kill)
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
				echo "hascrashed=false" > $twitteralertsfile
				echo $dateformat"_"$timeformat "- Process kill attempt logged." >> $statuslog

				echo "Attempting to kill rogue $server_File process..."

				# Get the Process ID of running JAR file
				serverPID=`ps ax | grep -v grep | grep -v -i tmux | grep -v sh | grep "$server_File"`
				kill -9 ${serverPID:0:5}
				sleep 10

				# Check for process status after pkill attempt
				if isrunning; then
					echo "$server_File could not be killed!"
					echo $dateformat"_"$timeformat "- Process kill attempt failed." >> $statuslog
					exit 1
				else
					echo "$server_File process terminated!"
					echo $dateformat"_"$timeformat "- Process kill attempt succeeded." >> $statuslog
				fi
			fi
		fi
		;;
	*)
		help
esac

exit