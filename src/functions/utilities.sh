#!/bin/bash

sendtoscreen() {
	#screen -q -S minecraft -p bukkit -X stuff "$1$(echo -ne '\r')" > /dev/null
	screen -q -S $bukkitscreen -X stuff "`printf "\r"`" #clears the consoles input area prior to sending the intended command
	screen -q -S $bukkitscreen -X stuff "$1$(echo -ne '\r')" > /dev/null
}

isrunning() {
	ps ax | grep -v grep | grep -v screen | grep "$bukkitfilename" > /dev/null
	return $?
}

resumebukkit() {
	screen -x $bukkitscreen
}

logroll() {
	if isrunning; then
		echo "Stop the Minecraft server before rolling logs!"
	else
		cd $bukkitdir
		for ((i=0;i<$numlogroll;i++)); do
			mv ${logroll[$i]}.log ${logdir}/${logroll[$i]}/${dateformat}.log
		done
	fi
}