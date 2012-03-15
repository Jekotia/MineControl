#!/bin/bash
. /home/mc/scripts/init.sh

help(){
# echo "Usage: $0 [status|start|stop|restart|friendlystop|resume]"
	echo "Usage: MC <status|start|stop|resume|kill>"
}

case $1 in
	status)
		if isrunning; then
			echo "Minecraft server currently ONLINE:"
			# Get the Process ID of running JAR file
			bukkitPID=`ps ax | grep -v grep | grep -v sh | grep -v -i 'screen' | grep "$bukkitfilename"`

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
		startbukkit
		;;
	stop)
		stopbukkit
		;;
	restart)
		#stopbukkit
		#sleep 5
		#startbukkit
		echo "Needs testing still. Sorry!"
		;;
	friendlystop)
		#stop friendly
		echo "Needs testing still. Sorry!"
		;;
	resume)
		resumebukkit
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

				echo "Attempting to kill rogue $bukkitfilename process..."

				# Get the Process ID of running JAR file
				bukkitPID=`ps ax | grep -v grep | grep -v -i tmux | grep -v sh | grep "$bukkitfilename"`
				kill -9 ${bukkitPID:0:5}
				sleep 10

				# Check for process status after pkill attempt
				if isrunning; then
					echo "$bukkitfilename could not be killed!"
					echo $dateformat"_"$timeformat "- Process kill attempt failed." >> $statuslog
					exit 1
				else
					echo "$bukkitfilename process terminated!"
					echo $dateformat"_"$timeformat "- Process kill attempt succeeded." >> $statuslog
				fi
			fi
		fi
		;;
	*)
		help
esac

exit